package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.api.ShopApiParams;
import cn.qihangerp.enums.EnumShopType;
import cn.qihangerp.erp.controller.oms.pdd.PddApiCommon;
import cn.qihangerp.erp.service.ShopPullApiService;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.open.common.ApiResultVo;
import cn.qihangerp.open.pdd.PddGoodsApiHelper;
import cn.qihangerp.open.pdd.PddOrderApiHelper;
import cn.qihangerp.open.pdd.PddRefundApiHelper;
import cn.qihangerp.open.pdd.model.AfterSale;
import cn.qihangerp.open.pdd.model.Goods;
import cn.qihangerp.open.pdd.model.GoodsSku;
import cn.qihangerp.open.pdd.model.Order;
import cn.qihangerp.open.pdd.model.OrderItem;
import cn.qihangerp.service.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * OMS 统一拉取服务实现（PDD 分支）。<br>
 * 流程：PDD 平台 SDK 拉原始数据 → 转换为统一实体 → 保存到 oms_shop_* 表 → 同步到 o_order / o_refund。<br>
 * 其它平台（TAO/JD/DOU/WEI/KWAI/XHS）可按相同模式在本类中扩展 shopType 分支。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ShopPullApiServiceImpl implements ShopPullApiService {

    private final PddApiCommon pddApiCommon;
    private final OShopService shopService;
    private final ShopOrderService shopOrderService;
    private final ShopRefundService shopRefundService;
    private final ShopGoodsService shopGoodsService;
    private final OOrderService oOrderService;
    private final ORefundService oRefundService;
    private final OShopPullLogsService pullLogsService;
    private final OShopPullLasttimeService pullLasttimeService;

    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter DT_SHORT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    // ============================== 订单 ==============================

    @Override
    public ResultVo<String> pullOrder(Long shopId, String startTime, String endTime) {
        if (shopId == null || shopId <= 0) return ResultVo.error("参数错误，没有店铺Id");
        if (!StringUtils.hasText(startTime)) return ResultVo.error("请选择订单日期");

        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error("店铺不存在");

        if (shop.getType() == EnumShopType.PDD.getIndex()) {
            return pullPddOrder(shop, startTime, endTime);
        }
        return ResultVo.error("暂未支持该平台(" + shop.getType() + ")的订单拉取");
    }

    private ResultVo<String> pullPddOrder(OShop shop, String startTime, String endTime) {
        long beginTime = System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();

        var check = pddApiCommon.checkBefore(shop.getId());
        if (check.getCode() != 200) return ResultVo.error(check.getCode(), check.getMsg());

        ShopApiParams p = check.getData();
        String appKey = p.getAppKey();
        String appSecret = p.getAppSecret();
        String accessToken = p.getAccessToken();

        // 按天拉取：startTime/endTime 为 yyyy-MM-dd
        LocalDateTime startLdt = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime endLdt = StringUtils.hasText(endTime)
                ? LocalDateTime.parse(endTime + " 23:59:59", DT)
                : LocalDateTime.parse(startTime + " 23:59:59", DT);
        int startTs = (int) startLdt.toEpochSecond(ZoneOffset.ofHours(8));
        int endTs = (int) endLdt.toEpochSecond(ZoneOffset.ofHours(8));
        String pullParams = "{startTime:" + startLdt.format(DT) + ",endTime:" + endLdt.format(DT) + "}";

        ApiResultVo<cn.qihangerp.open.pdd.model.OrderListResultVo> upResult;
        try {
            upResult = PddOrderApiHelper.pullOrderList(appKey, appSecret, accessToken, startTs, endTs, 1, 100);
        } catch (Exception e) {
            log.error("拉取PDD订单异常", e);
            saveLog(shop, "ORDER", "主动拉取订单", pullParams, "接口异常:" + e.getMessage(), beginTime, now);
            return ResultVo.error("接口拉取异常:" + e.getMessage());
        }
        if (upResult.getCode() != 0) {
            saveLog(shop, "ORDER", "主动拉取订单", pullParams, upResult.getMsg(), beginTime, now);
            return ResultVo.error("接口拉取错误:" + upResult.getMsg());
        }

        int insertSuccess = 0, hasExist = 0, totalError = 0;
        List<Order> orderList = upResult.getData().getOrderList();
        if (orderList != null) {
            for (Order trade : orderList) {
                try {
                    ShopOrder shopOrder = convertPddOrder(trade);
                    var result = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), shopOrder);
                    Long shopOrderId = result.getData();
                    // 同步到 o_order（无论新增还是更新都同步）
                    if (shopOrderId != null && shopOrderId > 0) {
                        try {
                            oOrderService.shopOrderMessage(shopOrderId);
                        } catch (Exception ex) {
                            log.error("同步PDD订单到o_order异常，shopOrderId={}", shopOrderId, ex);
                        }
                    }
                    if (result.getCode() == 1800) hasExist++;
                    else if (result.getCode() == 0) insertSuccess++;
                    else totalError++;
                } catch (Exception e) {
                    log.error("保存PDD订单异常:{}", trade.getOrderSn(), e);
                    totalError++;
                }
            }
        }

        String resultStr = "{insert:" + insertSuccess + ",update:" + hasExist + ",fail:" + totalError + "}";
        saveLog(shop, "ORDER", "主动拉取订单", pullParams, resultStr, beginTime, now);
        String msg = "总共找到：" + (orderList == null ? 0 : orderList.size()) + "条订单，新增：" + insertSuccess
                + "条，更新：" + hasExist + "条，失败：" + totalError + "条";
        log.info("/**************主动拉取PDD订单 END：{}****************/", msg);
        return ResultVo.success(msg);
    }

    @Override
    public ResultVo<String> pullOrderDetail(Long shopId, String orderId) {
        if (shopId == null || shopId <= 0) return ResultVo.error("参数错误，没有店铺Id");
        if (!StringUtils.hasText(orderId)) return ResultVo.error("参数错误，缺少orderId");
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error("店铺不存在");
        if (shop.getType() == EnumShopType.PDD.getIndex()) {
            return pullPddOrderDetail(shop, orderId);
        }
        return ResultVo.error("暂未支持该平台的订单详情拉取");
    }

    private ResultVo<String> pullPddOrderDetail(OShop shop, String orderId) {
        long beginTime = System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();
        var check = pddApiCommon.checkBefore(shop.getId());
        if (check.getCode() != 200) return ResultVo.error(check.getCode(), check.getMsg());
        ShopApiParams p = check.getData();

        ApiResultVo<Order> resultVo;
        try {
            resultVo = PddOrderApiHelper.pullOrderDetail(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), orderId);
        } catch (Exception e) {
            log.error("拉取PDD订单详情异常", e);
            return ResultVo.error("接口拉取异常:" + e.getMessage());
        }
        if (resultVo.getCode() != 0) {
            return ResultVo.error(resultVo.getCode(), resultVo.getMsg());
        }
        ShopOrder shopOrder = convertPddOrder(resultVo.getData());
        var result = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), shopOrder);
        Long shopOrderId = result.getData();
        if (shopOrderId != null && shopOrderId > 0) {
            try {
                oOrderService.shopOrderMessage(shopOrderId);
            } catch (Exception ex) {
                log.error("同步PDD订单详情到o_order异常，shopOrderId={}", shopOrderId, ex);
            }
        }
        saveLog(shop, "ORDER", "主动拉取订单详情", "{orderId:" + orderId + "}",
                "{code:" + result.getCode() + "}", beginTime, now);
        return ResultVo.success("订单[" + orderId + "]同步完成");
    }

    /**
     * PDD Order → 统一 ShopOrder（金额：元→分）
     */
    private ShopOrder convertPddOrder(Order trade) {
        ShopOrder o = new ShopOrder();
        o.setOrderId(trade.getOrderSn());
        o.setOrderTime(toEpochSecond(trade.getCreatedTime()));
        o.setUpdateTime(toEpochSecond(trade.getUpdatedAt()));
        o.setOrderTimeText(trade.getCreatedTime());
        o.setUpdateTimeText(trade.getUpdatedAt());
        o.setOrderStatus(trade.getOrderStatus());
        o.setRefundStatus(trade.getRefundStatus());
        o.setGoodsAmount(toFen(trade.getGoodsAmount()));
        o.setOrderAmount(toFen(trade.getPayAmount()));
        o.setFreight(toFen(trade.getPostage()));
        o.setPaymentAmount(toFen(trade.getPayAmount()));
        o.setPaymentMethod(trade.getPayType());
        o.setPayTime(toEpochSecond(trade.getPayTime()));
        o.setDiscountAmount(toFen(trade.getDiscountAmount()));
        o.setSellerDiscount(toFen(trade.getSellerDiscount()));
        o.setPlatformDiscount(toFen(trade.getPlatformDiscount()));
        o.setChangePrice(toFen(trade.getOrderChangeAmount()));
        o.setBuyerMemo(trade.getBuyerMemo());
        o.setRemark(trade.getRemark());
        o.setProvince(trade.getProvince());
        o.setCity(trade.getCity());
        o.setCounty(trade.getTown());
        o.setAddress(trade.getReceiverAddress());
        o.setReceiverName(trade.getReceiverName());
        o.setReceiverPhone(trade.getReceiverPhone());
        o.setShipDoneTime(toEpochSecond(trade.getShippingTime()));
        o.setFinishTime(toEpochSecond(trade.getReceiveTime()));
        o.setLatestDeliveryTime(toEpochSecond(trade.getLastShipTime()));
        o.setPlatformType(EnumShopType.PDD.getName());

        List<ShopOrderItem> items = new ArrayList<>();
        if (trade.getItemList() != null) {
            for (OrderItem it : trade.getItemList()) {
                ShopOrderItem item = new ShopOrderItem();
                item.setOrderId(trade.getOrderSn());
                item.setProductId(String.valueOf(it.getGoodsId()));
                item.setSkuId(String.valueOf(it.getSkuId()));
                item.setTitle(it.getGoodsName());
                item.setImg(it.getGoodsImg());
                item.setQuantity(it.getGoodsCount());
                item.setSalePrice(toFen(it.getGoodsPrice()));
                item.setOuterProductId(it.getOuterGoodsId());
                item.setOuterSkuId(it.getOuterId());
                item.setSkuName(it.getGoodsSpec());
                item.setOrderTime(o.getOrderTime());
                items.add(item);
            }
        }
        o.setItems(items);
        return o;
    }

    // ============================== 售后 ==============================

    @Override
    public ResultVo<String> pullRefund(Long shopId) {
        if (shopId == null || shopId <= 0) return ResultVo.error("参数错误，没有店铺Id");
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error("店铺不存在");
        if (shop.getType() == EnumShopType.PDD.getIndex()) {
            return pullPddRefund(shop);
        }
        return ResultVo.error("暂未支持该平台的售后拉取");
    }

    private ResultVo<String> pullPddRefund(OShop shop) {
        long beginTime = System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();
        var check = pddApiCommon.checkBefore(shop.getId());
        if (check.getCode() != 200) return ResultVo.error(check.getCode(), check.getMsg());
        ShopApiParams p = check.getData();

        // 增量：取上次拉取时间，没有则取最近30分钟
        LocalDateTime startLdt;
        LocalDateTime endLdt = LocalDateTime.now();
        OShopPullLasttime lasttime = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        if (lasttime == null) {
            startLdt = endLdt.minusMinutes(30);
        } else {
            startLdt = lasttime.getLasttime().minusMinutes(5);
        }
        int startTs = (int) startLdt.toEpochSecond(ZoneOffset.ofHours(8));
        int endTs = (int) endLdt.toEpochSecond(ZoneOffset.ofHours(8));
        String pullParams = "{startTime:" + startLdt.format(DT) + ",endTime:" + endLdt.format(DT) + "}";

        ApiResultVo<AfterSale> upResult;
        try {
            upResult = PddRefundApiHelper.pullRefundList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), startTs, endTs, 1, 20);
        } catch (Exception e) {
            log.error("拉取PDD售后异常", e);
            saveLog(shop, "REFUND", "主动拉取退款", pullParams, "接口异常:" + e.getMessage(), beginTime, now);
            return ResultVo.error("接口拉取异常:" + e.getMessage());
        }
        if (upResult.getCode() != 0) {
            saveLog(shop, "REFUND", "主动拉取退款", pullParams, upResult.getMsg(), beginTime, now);
            return ResultVo.error("接口拉取错误:" + upResult.getMsg());
        }

        int insertSuccess = 0, hasExist = 0, totalError = 0;
        List<AfterSale> list = upResult.getList();
        if (list != null) {
            for (AfterSale refund : list) {
                try {
                    ShopRefund shopRefund = convertPddRefund(refund);
                    var result = shopRefundService.saveRefund(shop.getId(), shopRefund);
                    Long shopRefundId = result.getData();
                    if (shopRefundId != null && shopRefundId > 0) {
                        try {
                            oRefundService.shopRefundMessage(shopRefundId);
                        } catch (Exception ex) {
                            log.error("同步PDD售后到o_refund异常，shopRefundId={}", shopRefundId, ex);
                        }
                    }
                    if (result.getCode() == 0) insertSuccess++;
                    else hasExist++;
                } catch (Exception e) {
                    log.error("保存PDD售后异常:{}", refund.getId(), e);
                    totalError++;
                }
            }
        }

        // 全部成功才更新最后拉取时间
        if (totalError == 0) {
            upsertLasttime(shop.getId(), "REFUND", endLdt, lasttime);
        }
        String resultStr = "{insert:" + insertSuccess + ",update:" + hasExist + ",fail:" + totalError + "}";
        saveLog(shop, "REFUND", "主动拉取退款", pullParams, resultStr, beginTime, now);
        String msg = "总共找到：" + (list == null ? 0 : list.size()) + "条，新增：" + insertSuccess
                + "条，更新：" + hasExist + "条，失败：" + totalError + "条";
        log.info("/**************主动拉取PDD退款 END：{}****************/", msg);
        return ResultVo.success(msg);
    }

    @Override
    public ResultVo<String> pullRefundDetail(Long shopId, String afterId) {
        if (shopId == null || shopId <= 0) return ResultVo.error("参数错误，没有店铺Id");
        if (!StringUtils.hasText(afterId)) return ResultVo.error("参数错误，缺少afterId");
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error("店铺不存在");
        if (shop.getType() != EnumShopType.PDD.getIndex()) {
            return ResultVo.error("暂未支持该平台的售后详情拉取");
        }
        long beginTime = System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();
        var check = pddApiCommon.checkBefore(shop.getId());
        if (check.getCode() != 200) return ResultVo.error(check.getCode(), check.getMsg());
        ShopApiParams p = check.getData();

        ApiResultVo<AfterSale> resultVo;
        try {
            // PDD 售后详情需要 afterSalesId + orderSn，这里 afterId 作为 afterSalesId，orderSn 暂传空
            resultVo = PddRefundApiHelper.pullRefundDetil(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), afterId, null);
        } catch (Exception e) {
            log.error("拉取PDD售后详情异常", e);
            return ResultVo.error("接口拉取异常:" + e.getMessage());
        }
        if (resultVo.getCode() != 0) {
            return ResultVo.error(resultVo.getCode(), resultVo.getMsg());
        }
        ShopRefund shopRefund = convertPddRefund(resultVo.getData());
        var result = shopRefundService.saveRefund(shop.getId(), shopRefund);
        Long shopRefundId = result.getData();
        if (shopRefundId != null && shopRefundId > 0) {
            try {
                oRefundService.shopRefundMessage(shopRefundId);
            } catch (Exception ex) {
                log.error("同步PDD售后详情到o_refund异常，shopRefundId={}", shopRefundId, ex);
            }
        }
        saveLog(shop, "REFUND", "主动拉取退款详情", "{afterId:" + afterId + "}",
                "{code:" + result.getCode() + "}", beginTime, now);
        return ResultVo.success("售后[" + afterId + "]同步完成");
    }

    /**
     * PDD AfterSale → 统一 ShopRefund（金额：元→分）
     */
    private ShopRefund convertPddRefund(AfterSale refund) {
        ShopRefund r = new ShopRefund();
        r.setAfterId(refund.getId() == null ? null : refund.getId().toString());
        r.setType(refund.getAfterSalesType());
        r.setStatus(refund.getAfterSalesStatus());
        r.setOrderId(refund.getOrderSn());
        r.setOrderAmount(toFen(refund.getOrderAmount()));
        r.setProductId(refund.getGoodsId() == null ? null : refund.getGoodsId().toString());
        r.setGoodsName(refund.getGoodsName());
        r.setGoodsImage(refund.getGoodImage());
        r.setSkuId(refund.getSkuId());
        r.setCount(refund.getGoodsNumber());
        r.setRefundAmount(toFen(refund.getRefundAmount()));
        r.setReturnWaybillId(refund.getTrackingNumber());
        r.setReturnDeliveryName(refund.getShippingName());
        r.setCreateTime(toEpochSecond(refund.getCreatedTime()));
        r.setUpdateTime(toEpochSecond(refund.getUpdatedTime()));
        r.setReason(refund.getAfterSaleReason());
        r.setOuterId(refund.getOuterId());
        r.setGoodsPrice(toFen(refund.getGoodsPrice()));
        r.setDisputeRefundStatus(refund.getDisputeRefundStatus());
        r.setPlatformType(EnumShopType.PDD.getName());
        return r;
    }

    // ============================== 商品 ==============================

    @Override
    public ResultVo<String> pullGoods(Long shopId, Integer pullType) {
        if (shopId == null || shopId <= 0) return ResultVo.error("参数错误，没有店铺Id");
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error("店铺不存在");
        if (shop.getType() == EnumShopType.PDD.getIndex()) {
            return pullPddGoods(shop, pullType == null ? 0 : pullType);
        }
        return ResultVo.error("暂未支持该平台的商品拉取");
    }

    private ResultVo<String> pullPddGoods(OShop shop, Integer pullType) {
        long beginTime = System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();
        var check = pddApiCommon.checkBefore(shop.getId());
        if (check.getCode() != 200) return ResultVo.error(check.getCode(), check.getMsg());
        ShopApiParams p = check.getData();

        String pullParams = "{pullType:" + pullType + "}";
        ApiResultVo<cn.qihangerp.open.pdd.model.GoodsResultVo> resultVo;
        try {
            resultVo = PddGoodsApiHelper.pullGoodsList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), 1, 20);
        } catch (Exception e) {
            log.error("拉取PDD商品异常", e);
            saveLog(shop, "GOODS", "主动拉取商品", pullParams, "接口异常:" + e.getMessage(), beginTime, now);
            return ResultVo.error("接口拉取异常:" + e.getMessage());
        }
        if (resultVo.getCode() != 0) {
            saveLog(shop, "GOODS", "主动拉取商品", pullParams, resultVo.getMsg(), beginTime, now);
            return ResultVo.error("接口拉取错误:" + resultVo.getMsg());
        }

        int successTotal = 0;
        List<Goods> goodsList = resultVo.getData().getGoodsList();
        if (goodsList != null) {
            for (Goods g : goodsList) {
                try {
                    ShopGoods shopGoods = convertPddGoods(g);
                    shopGoodsService.savePddGoods(shopGoods, shop.getId());
                    successTotal++;
                } catch (Exception e) {
                    log.error("保存PDD商品异常:{}", g.getGoodsId(), e);
                }
            }
        }

        // 更新最后拉取时间
        OShopPullLasttime lasttime = pullLasttimeService.getLasttimeByShop(shop.getId(), "GOODS");
        upsertLasttime(shop.getId(), "GOODS", LocalDateTime.now(), lasttime);

        saveLog(shop, "GOODS", "主动拉取商品", pullParams, "{successTotal:" + successTotal + "}", beginTime, now);
        String msg = "接口拉取成功，总数据：" + successTotal;
        log.info("/**************主动拉取PDD商品 END：{}****************/", msg);
        return ResultVo.success(msg);
    }

    /**
     * PDD Goods → 统一 ShopGoods（含 SKU）
     */
    private ShopGoods convertPddGoods(Goods g) {
        ShopGoods goods = new ShopGoods();
        goods.setProductId(String.valueOf(g.getGoodsId()));
        goods.setTitle(g.getGoodsName());
        goods.setImg(g.getThumbUrl());
        goods.setImgs(g.getImageUrl());
        goods.setQuantity(g.getGoodsQuantity());
        goods.setStatus(g.getIsOnsale());
        goods.setAddTime((long) g.getCreatedAt());

        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (g.getSkuList() != null) {
            String outerProductId = null;
            for (GoodsSku s : g.getSkuList()) {
                ShopGoodsSku sku = new ShopGoodsSku();
                sku.setSkuId(String.valueOf(s.getSkuId()));
                sku.setOuterSkuId(s.getOuterId());
                sku.setOuterProductId(s.getOuterGoodsId());
                sku.setStockNum(s.getSkuQuantity());
                sku.setStatus(s.getIsSkuOnsale());
                sku.setSkuName(s.getSpec());
                skuList.add(sku);
                if (outerProductId == null && StringUtils.hasText(s.getOuterGoodsId())) {
                    outerProductId = s.getOuterGoodsId();
                }
            }
            goods.setOuterProductId(outerProductId);
            goods.setSpuCode(outerProductId);
        }
        goods.setSkuList(skuList);
        return goods;
    }

    // ============================== 工具方法 ==============================

    /** 元 → 分（Double/Integer/null 安全） */
    private Integer toFen(Double yuan) {
        if (yuan == null) return 0;
        return (int) Math.round(yuan * 100);
    }

    private Integer toFen(String yuan) {
        if (!StringUtils.hasText(yuan)) return 0;
        try {
            return (int) Math.round(Double.parseDouble(yuan) * 100);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private Integer toFen(double yuan) {
        return (int) Math.round(yuan * 100);
    }

    /** yyyy-MM-dd HH:mm:ss 字符串 → 秒级时间戳，失败返回 null */
    private Long toEpochSecond(String time) {
        if (!StringUtils.hasText(time)) return null;
        try {
            return LocalDateTime.parse(time, DT).toEpochSecond(ZoneOffset.ofHours(8));
        } catch (DateTimeParseException e) {
            try {
                return LocalDateTime.parse(time, DateTimeFormatter.ISO_LOCAL_DATE_TIME).toEpochSecond(ZoneOffset.ofHours(8));
            } catch (Exception ignored) {
                return null;
            }
        }
    }

    private void saveLog(OShop shop, String pullType, String pullWay, String pullParams, String pullResult,
                         long beginTime, LocalDateTime pullTime) {
        try {
            OShopPullLogs logs = new OShopPullLogs();
            logs.setShopId(shop.getId());
            logs.setMerchantId(shop.getMerchantId());
            logs.setShopType(shop.getType());
            logs.setPullType(pullType);
            logs.setPullWay(pullWay);
            logs.setPullParams(pullParams);
            logs.setPullResult(pullResult);
            logs.setPullTime(pullTime);
            logs.setDuration(System.currentTimeMillis() - beginTime);
            pullLogsService.save(logs);
        } catch (Exception e) {
            log.error("保存拉取日志失败", e);
        }
    }

    private void upsertLasttime(Long shopId, String pullType, LocalDateTime lasttime, OShopPullLasttime exist) {
        try {
            if (exist == null) {
                OShopPullLasttime insert = new OShopPullLasttime();
                insert.setShopId(shopId);
                insert.setPullType(pullType);
                insert.setLasttime(lasttime);
                insert.setCreateTime(LocalDateTime.now());
                pullLasttimeService.save(insert);
            } else {
                OShopPullLasttime update = new OShopPullLasttime();
                update.setId(exist.getId());
                update.setLasttime(lasttime);
                update.setUpdateTime(LocalDateTime.now());
                pullLasttimeService.updateById(update);
            }
        } catch (Exception e) {
            log.error("更新拉取最后时间失败", e);
        }
    }
}
