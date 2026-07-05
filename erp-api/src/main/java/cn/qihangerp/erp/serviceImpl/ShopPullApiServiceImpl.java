package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.api.ShopApiParams;
import cn.qihangerp.erp.service.ShopApiCommon;
import cn.qihangerp.erp.service.ShopPullApiService;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.open.common.ApiResultVo;
import cn.qihangerp.open.pdd.PddGoodsApiHelper;
import cn.qihangerp.open.pdd.PddOrderApiHelper;
import cn.qihangerp.open.pdd.PddRefundApiHelper;
import cn.qihangerp.open.tao.TaoGoodsApiHelper;
import cn.qihangerp.open.tao.TaoOrderApiHelper;
import cn.qihangerp.open.tao.TaoRefundApiHelper;
import cn.qihangerp.open.jd.JdOrderApiHelper;
import cn.qihangerp.open.jd.JdGoodsApiHelper;
import cn.qihangerp.open.jd.JdAfterSaleApiHelper;
import cn.qihangerp.open.jd.response.JdOrderListResponse;
import cn.qihangerp.open.jd.response.JdOrderDetailResponse;
import cn.qihangerp.open.jd.response.JdOrderItemResponse;
import cn.qihangerp.open.jd.response.JdGoodsSkuListResponse;
import cn.qihangerp.open.jd.model.AfterSale;
import cn.qihangerp.open.jd.model.Refund;
import cn.qihangerp.open.dou.DouOrderApiHelper;
import cn.qihangerp.open.dou.DouRefundApiHelper;
import cn.qihangerp.open.dou.DouGoodsApiHelper;
import cn.qihangerp.open.dou.model.GoodsListResultVo;
import cn.qihangerp.open.dou.model.Goods;
import cn.qihangerp.open.dou.model.GoodsSku;
import cn.qihangerp.open.wei.WeiOrderApiHelper;
import cn.qihangerp.open.wei.WeiRefundApiHelper;
import cn.qihangerp.open.wei.WeiGoodsApiHelper;
import cn.qihangerp.open.wei.model.Order;
import cn.qihangerp.open.wei.model.AfterSaleOrder;
import cn.qihangerp.open.wei.model.Product;
import cn.qihangerp.open.kwai.KwaiOrderApiHelper;
import cn.qihangerp.open.kwai.KwaiGoodsApiHelper;
import cn.qihangerp.open.kwai.KwaiRefundApiHelper;
import cn.qihangerp.open.kwai.model.KwaiGoodsItem;
import cn.qihangerp.service.*;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * OMS 统一拉取服务实现。
 * <p>已实现平台：PDD(300) 完整 + TAO(100) 订单/售后/商品</p>
 * <p>待补充平台：JD(200)、DOU(400)、WEI(500) — model 转换逻辑需按各平台 SDK model 结构补充</p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ShopPullApiServiceImpl implements ShopPullApiService {

    private final ShopApiCommon shopApiCommon;
    private final OShopService shopService;
    private final ShopOrderService shopOrderService;
    private final ShopRefundService shopRefundService;
    private final ShopGoodsService shopGoodsService;
    private final OOrderService oOrderService;
    private final ORefundService oRefundService;
    private final OShopPullLogsService pullLogsService;
    private final OShopPullLasttimeService pullLasttimeService;

    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    // ======================== 路由器 ========================

    @Override
    public ResultVo<String> pullOrder(Long shopId, String startTime, String endTime) {
        OShop shop = getShop(shopId); if (shop == null) return ResultVo.error("店铺不存在");
        if (!StringUtils.hasText(startTime)) return ResultVo.error("请选择订单日期");
        long begin = System.currentTimeMillis();
        return switch (shop.getType()) {
            case 300 -> pullPddOrder(shop, startTime, endTime, begin);
            case 100 -> pullTaoOrder(shop, startTime, endTime, begin);
            case 200 -> pullJdOrder(shop, startTime, endTime, begin);
            case 400 -> pullDouOrder(shop, startTime, endTime, begin);
            default -> ResultVo.error("该平台(" + shop.getType() + ")订单拉取待实现");
        };
    }
    @Override
    public ResultVo<String> pullOrderDetail(Long shopId, String orderId) {
        OShop shop = getShop(shopId); if (shop == null) return ResultVo.error("店铺不存在");
        if (!StringUtils.hasText(orderId)) return ResultVo.error("缺少orderId");
        long begin = System.currentTimeMillis();
        return switch (shop.getType()) {
            case 300 -> pullPddOrderDetail(shop, orderId, begin);
            case 100 -> pullTaoOrderDetail(shop, orderId, begin);
            case 200 -> pullJdOrderDetail(shop, orderId, begin);
            case 400 -> pullDouOrderDetail(shop, orderId, begin);
            default -> ResultVo.error("该平台订单详情拉取待实现");
        };
    }
    @Override
    public ResultVo<String> pullRefund(Long shopId) {
        OShop shop = getShop(shopId); if (shop == null) return ResultVo.error("店铺不存在");
        long begin = System.currentTimeMillis();
        return switch (shop.getType()) {
            case 300 -> pullPddRefund(shop, begin);
            case 100 -> pullTaoRefund(shop, begin);
            case 200 -> pullJdRefund(shop, begin);
            case 400 -> pullDouRefund(shop, begin);
            default -> ResultVo.error("该平台售后拉取待实现");
        };
    }
    @Override
    public ResultVo<String> pullRefundDetail(Long shopId, String afterId) {
        OShop shop = getShop(shopId); if (shop == null) return ResultVo.error("店铺不存在");
        if (!StringUtils.hasText(afterId)) return ResultVo.error("缺少afterId");
        long begin = System.currentTimeMillis();
        return switch (shop.getType()) {
            case 300 -> pullPddRefundDetail(shop, afterId, begin);
            case 100 -> pullTaoRefundDetail(shop, afterId, begin);
            case 200 -> pullJdRefundDetail(shop, afterId, begin);
            case 400 -> pullDouRefundDetail(shop, afterId, begin);
            default -> ResultVo.error("该平台售后详情拉取待实现");
        };
    }
    @Override
    public ResultVo<String> pullGoods(Long shopId, Integer pullType) {
        OShop shop = getShop(shopId); if (shop == null) return ResultVo.error("店铺不存在");
        long begin = System.currentTimeMillis();
        return switch (shop.getType()) {
            case 300 -> pullPddGoods(shop, pullType == null ? 0 : pullType, begin);
            case 100 -> pullTaoGoods(shop, begin);
            case 200 -> pullJdGoods(shop, begin);
            case 400 -> pullDouGoods(shop, begin);
            default -> ResultVo.error("该平台商品拉取待实现");
        };
    }

    // ======================== PDD ========================

    private ResultVo<String> pullPddOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 300); if (p == null) return err(shop, "ORDER", "参数校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        int ss = (int) s.toEpochSecond(ZoneOffset.ofHours(8)), ee = (int) e.toEpochSecond(ZoneOffset.ofHours(8));
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = PddOrderApiHelper.pullOrderList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), ss, ee, 1, 100);
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getData() != null && r.getData().getOrderList() != null) for (var t : r.getData().getOrderList()) {
                try { var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), toOrder(t));
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else if (sr.getCode() == 1800) upd++; else fail++;
                } catch (Exception ex) { log.error("PDD订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "PDD:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullPddOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 300); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = PddOrderApiHelper.pullOrderDetail(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), orderId);
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), toOrder(r.getData()));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "PDD detail:" + ex.getMessage(), begin); }
    }
    private ShopOrder toOrder(cn.qihangerp.open.pdd.model.Order t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("PDD"); o.setOrderId(t.getOrderSn());
        o.setOrderTime(ts(t.getCreatedTime())); o.setUpdateTime(ts(t.getUpdatedAt()));
        o.setOrderTimeText(t.getCreatedTime()); o.setOrderStatus(t.getOrderStatus()); o.setRefundStatus(t.getRefundStatus());
        o.setGoodsAmount(fen(t.getGoodsAmount())); o.setOrderAmount(fen(t.getPayAmount())); o.setFreight(fen(t.getPostage()));
        o.setPaymentAmount(fen(t.getPayAmount())); o.setPayTime(ts(t.getPayTime())); o.setPaymentMethod(t.getPayType());
        o.setDiscountAmount(fen(t.getDiscountAmount())); o.setSellerDiscount(fen(t.getSellerDiscount())); o.setPlatformDiscount(fen(t.getPlatformDiscount()));
        o.setChangePrice(fen(t.getOrderChangeAmount())); o.setBuyerMemo(t.getBuyerMemo()); o.setRemark(t.getRemark());
        o.setProvince(t.getProvince()); o.setCity(t.getCity()); o.setCounty(t.getTown()); o.setAddress(t.getReceiverAddress());
        o.setReceiverName(t.getReceiverName()); o.setReceiverPhone(t.getReceiverPhone());
        o.setShipDoneTime(ts(t.getShippingTime())); o.setFinishTime(ts(t.getReceiveTime())); o.setLatestDeliveryTime(ts(t.getLastShipTime()));
        List<ShopOrderItem> items = new ArrayList<>();
        if (t.getItemList() != null) for (var it : t.getItemList()) {
            ShopOrderItem i = new ShopOrderItem(); i.setOrderId(t.getOrderSn());
            i.setProductId(String.valueOf(it.getGoodsId())); i.setSkuId(String.valueOf(it.getSkuId()));
            i.setTitle(it.getGoodsName()); i.setImg(it.getGoodsImg()); i.setQuantity(it.getGoodsCount());
            i.setSalePrice(fen(it.getGoodsPrice())); i.setOuterProductId(it.getOuterGoodsId());
            i.setOuterSkuId(it.getOuterId()); i.setSkuName(it.getGoodsSpec()); i.setOrderTime(o.getOrderTime());
            items.add(i);
        }
        o.setItems(items);
        // saveOrder 需要这些默认值
        o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private ResultVo<String> pullPddRefund(OShop shop, long begin) {
        var p = chk(shop, 300); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusMinutes(30) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        int ss = (int) st.toEpochSecond(ZoneOffset.ofHours(8)), ee = (int) et.toEpochSecond(ZoneOffset.ofHours(8));
        String pp = "{st:" + st.format(DT) + "}";
        try {
            var r = PddRefundApiHelper.pullRefundList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), ss, ee, 1, 20);
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (var rf : r.getList()) {
                try { var rr = shopRefundService.saveRefund(shop.getId(), toRefund(rf));
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { fail++; log.error("PDD退款保存失败", ex); }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "PDD:" + ex.getMessage(), begin); }
    }
    private ShopRefund toRefund(cn.qihangerp.open.pdd.model.AfterSale rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("PDD");
        r.setAfterId(rf.getId() == null ? null : rf.getId().toString()); r.setType(rf.getAfterSalesType());
        r.setStatus(rf.getAfterSalesStatus()); r.setOrderId(rf.getOrderSn());
        r.setOrderAmount(fen(rf.getOrderAmount()));
        r.setProductId(rf.getGoodsId() == null ? null : rf.getGoodsId().toString());
        r.setGoodsName(rf.getGoodsName()); r.setGoodsImage(rf.getGoodImage()); r.setSkuId(rf.getSkuId());
        r.setCount(rf.getGoodsNumber()); r.setRefundAmount(fen(rf.getRefundAmount()));
        r.setReturnWaybillId(rf.getTrackingNumber()); r.setReturnDeliveryName(rf.getShippingName());
        r.setCreateTime(ts(rf.getCreatedTime())); r.setUpdateTime(ts(rf.getUpdatedTime()));
        r.setReason(rf.getAfterSaleReason()); r.setOuterId(rf.getOuterId());
        r.setGoodsPrice(fen(rf.getGoodsPrice())); r.setDisputeRefundStatus(rf.getDisputeRefundStatus());
        return r;
    }
    private ResultVo<String> pullPddRefundDetail(OShop shop, String afterId, long begin) {
        var p = chk(shop, 300); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        try {
            var r = PddRefundApiHelper.pullRefundDetil(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), afterId, null);
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), "{afterId:" + afterId + "}", begin);
            var rr = shopRefundService.saveRefund(shop.getId(), toRefund(r.getData()));
            if (rr.getData() != null) oRefundService.shopRefundMessage(rr.getData());
            logMsg(shop, "REFUND", "{afterId:" + afterId + "}", "{}", begin);
            return ResultVo.success("售后[" + afterId + "]同步完成");
        } catch (Exception ex) { return err(shop, "REFUND", "PDD detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullPddGoods(OShop shop, Integer pullType, long begin) {
        var p = chk(shop, 300); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = PddGoodsApiHelper.pullGoodsList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), 1, 20);
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getData() != null && r.getData().getGoodsList() != null) for (var g : r.getData().getGoodsList()) {
                try { shopGoodsService.savePddGoods(toGoods(g), shop.getId()); success++; } catch (Exception ex) { log.error("PDD商品保存失败", ex); }
            }
            upsertLt(shop.getId(), "GOODS", LocalDateTime.now(), null);
            logMsg(shop, "GOODS", "{pullType:" + pullType + "}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "PDD:" + ex.getMessage(), begin); }
    }
    private ShopGoods toGoods(cn.qihangerp.open.pdd.model.Goods g) {
        ShopGoods sg = new ShopGoods(); sg.setProductId(String.valueOf(g.getGoodsId())); sg.setTitle(g.getGoodsName());
        sg.setImg(g.getThumbUrl()); sg.setImgs(g.getImageUrl()); sg.setQuantity(g.getGoodsQuantity());
        sg.setStatus(g.getIsOnsale()); sg.setAddTime((long) g.getCreatedAt());
        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (g.getSkuList() != null) for (var s : g.getSkuList()) {
            ShopGoodsSku sk = new ShopGoodsSku(); sk.setSkuId(String.valueOf(s.getSkuId())); sk.setOuterSkuId(s.getOuterId());
            sk.setOuterProductId(s.getOuterGoodsId()); sk.setStockNum(s.getSkuQuantity()); sk.setStatus(s.getIsSkuOnsale());
            sk.setSkuName(s.getSpec()); skuList.add(sk);
            if (!StringUtils.hasText(sg.getOuterProductId()) && StringUtils.hasText(s.getOuterGoodsId())) sg.setOuterProductId(s.getOuterGoodsId());
        }
        sg.setSkuList(skuList); return sg;
    }

    // ======================== TAO（JSONObject 解析）=======================

    private ResultVo<String> pullTaoOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 100); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = TaoOrderApiHelper.pullOrderList(s, e, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getList() != null) for (Object tObj : r.getList()) {
                try { var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), taoOrder((JSONObject)(Object)tObj));
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else upd++;
                } catch (Exception ex) { log.error("TAO订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "TAO:" + ex.getMessage(), begin); }
    }
    private ShopOrder taoOrder(JSONObject t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("TAO"); o.setOrderId(t.getString("tid"));
        o.setOrderTime(ts(t.getString("created"))); o.setUpdateTime(ts(t.getString("modified"))); o.setOrderTimeText(t.getString("created"));
        String status = t.getString("status"); o.setPlatformOrderStatus(status);
        o.setOrderStatus("WAIT_BUYER_PAY".equals(status) ? 21 : "TRADE_CLOSED".equals(status) || "TRADE_CLOSED_BY_TAOBAO".equals(status) ? 13 : "WAIT_BUYER_CONFIRM_GOODS".equals(status) || "TRADE_BUYER_SIGNED".equals(status) ? 2 : "TRADE_FINISHED".equals(status) ? 3 : 1);
        o.setGoodsAmount(fen(t.getString("total_fee"))); o.setOrderAmount(fen(t.getString("payment")));
        o.setPaymentAmount(fen(t.getString("payment"))); o.setFreight(fen(t.getString("post_fee")));
        o.setDiscountAmount(fen(t.getString("discount_fee"))); o.setPayTime(ts(t.getString("pay_time")));
        o.setBuyerMemo(t.getString("buyer_message") != null ? t.getString("buyer_message") : t.getString("buyer_memo"));
        o.setRemark(t.getString("seller_memo"));
        o.setProvince(t.getString("receiver_state")); o.setCity(t.getString("receiver_city"));
        o.setCounty(t.getString("receiver_district")); o.setTown(t.getString("receiver_town"));
        o.setAddress(t.getString("receiver_address")); o.setReceiverName(t.getString("receiver_name"));
        o.setReceiverPhone(t.getString("receiver_mobile")); o.setFinishTime(ts(t.getString("end_time")));
        List<ShopOrderItem> items = new ArrayList<>();
        JSONArray orders = t.getJSONArray("orders");
        if (orders != null) for (int i = 0; i < orders.size(); i++) {
            JSONObject od = orders.getJSONObject(i); ShopOrderItem it = new ShopOrderItem();
            it.setOrderId(t.getString("tid")); it.setSubOrderId(od.getString("oid"));
            it.setProductId(od.getString("num_iid")); it.setSkuId(od.getString("sku_id"));
            it.setTitle(od.getString("title")); it.setImg(od.getString("pic_path")); it.setQuantity(od.getIntValue("num"));
            it.setSalePrice(fen(od.getString("price")));
            it.setOuterProductId(od.getString("outer_iid")); it.setOuterSkuId(od.getString("outer_sku_id"));
            it.setSkuName(od.getString("sku_properties_name")); it.setDiscountAmount(fen(od.getString("discount_fee")));
            it.setOrderTime(o.getOrderTime()); items.add(it);
        }
        o.setItems(items); o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private ResultVo<String> pullTaoOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 100); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = TaoOrderApiHelper.pullOrderDetail(orderId, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0 || r.getList() == null || r.getList().isEmpty()) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), taoOrder((JSONObject)(Object)r.getList().get(0)));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "TAO detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullTaoRefund(OShop shop, long begin) {
        var p = chk(shop, 100); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusDays(1) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        String pp = "{st:" + st.format(DT) + "}";
        try {
            var r = TaoRefundApiHelper.pullRefund(st, et, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (Object rfObj : r.getList()) {
                try { var rr = shopRefundService.saveRefund(shop.getId(), taoRefund((JSONObject)(Object)rfObj));
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { log.error("TAO退款保存失败", ex); fail++; }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "TAO:" + ex.getMessage(), begin); }
    }
    private ShopRefund taoRefund(JSONObject rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("TAO");
        r.setAfterId(rf.getString("refund_id")); r.setType(rf.getIntValue("has_good_return") == 1 ? 10 : 11);
        r.setStatus(rf.getIntValue("status")); r.setOrderId(rf.getString("tid"));
        r.setProductId(rf.getString("num_iid")); r.setGoodsName(rf.getString("title"));
        r.setGoodsImage(rf.getString("pic_path")); r.setSkuId(rf.getString("sku"));
        r.setCount(rf.getIntValue("num")); r.setRefundAmount(fen(rf.getString("refund_fee")));
        r.setOrderAmount(fen(rf.getString("total_fee")));
        r.setReason(rf.getString("reason")); r.setOuterId(rf.getString("outer_id"));
        r.setCreateTime(ts(rf.getString("created"))); r.setUpdateTime(ts(rf.getString("modified")));
        return r;
    }
    private ResultVo<String> pullTaoRefundDetail(OShop shop, String refundId, long begin) {
        var p = chk(shop, 100); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        try {
            var r = TaoRefundApiHelper.pullRefundDetail(Long.parseLong(refundId), p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "REFUND", r.getMsg(), "{refundId:" + refundId + "}", begin);
            var rr = shopRefundService.saveRefund(shop.getId(), taoRefund((JSONObject)(Object)r.getData()));
            if (rr.getData() != null) oRefundService.shopRefundMessage(rr.getData());
            logMsg(shop, "REFUND", "{refundId:" + refundId + "}", "{}", begin);
            return ResultVo.success("售后[" + refundId + "]同步完成");
        } catch (Exception ex) { return err(shop, "REFUND", "TAO detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullTaoGoods(OShop shop, long begin) {
        var p = chk(shop, 100); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = TaoGoodsApiHelper.pullGoodsList(p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getList() != null) for (Object gObj : r.getList()) {
                try { shopGoodsService.savePddGoods(taoGoods((JSONObject)(Object)gObj), shop.getId()); success++; } catch (Exception ex) { log.error("TAO商品保存失败", ex); }
            }
            logMsg(shop, "GOODS", "{}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "TAO:" + ex.getMessage(), begin); }
    }
    private ShopGoods taoGoods(JSONObject g) {
        ShopGoods sg = new ShopGoods(); sg.setProductId(g.getString("num_iid")); sg.setTitle(g.getString("title"));
        sg.setImg(g.getString("pic_url")); sg.setOuterProductId(g.getString("outer_id"));
        String lt = g.getString("list_time"); if (StringUtils.hasText(lt)) sg.setAddTime(ts(lt));
        JSONArray skus = g.getJSONArray("skus");
        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (skus != null) for (int i = 0; i < skus.size(); i++) {
            JSONObject s = skus.getJSONObject(i); ShopGoodsSku sk = new ShopGoodsSku();
            sk.setSkuId(s.getString("sku_id")); sk.setOuterSkuId(s.getString("outer_id"));
            sk.setPrice(fen(s.getString("price"))); sk.setStockNum(s.getIntValue("quantity"));
            skuList.add(sk);
        }
        sg.setSkuList(skuList); return sg;
    }

    // ======================== JD 京东POP ========================

    private ResultVo<String> pullJdOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 200); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = JdOrderApiHelper.pullOrder(s, e, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getList() != null) for (var t : r.getList()) {
                try { var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), jdOrder(t));
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else upd++;
                } catch (Exception ex) { log.error("JD订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "JD:" + ex.getMessage(), begin); }
    }
    private ShopOrder jdOrder(JdOrderListResponse t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("JD"); o.setOrderId(t.getOrderId());
        o.setPlatformOrderStatus(t.getOrderState()); o.setOrderStatus(jdStatus(t.getOrderState()));
        o.setGoodsAmount(fen(t.getOrderTotalPrice())); o.setOrderAmount(fen(t.getOrderPayment()));
        o.setPaymentAmount(fen(t.getOrderPayment())); o.setFreight(fen(t.getFreightPrice()));
        o.setSellerDiscount(fen(t.getSellerDiscount()));
        o.setPaymentMethod(t.getPayType());
        o.setOrderTimeText(t.getOrderStartTime()); o.setUpdateTimeText(t.getModified());
        o.setOrderTime(ts(t.getOrderStartTime())); o.setUpdateTime(ts(t.getModified()));
        o.setPayTime(ts(t.getPaymentConfirmTime())); o.setFinishTime(ts(t.getOrderEndTime()));
        o.setRemark(t.getOrderRemark());
        if (t.getConsigneeInfo() != null) {
            o.setProvince(t.getConsigneeInfo().getProvince()); o.setCity(t.getConsigneeInfo().getCity());
            o.setCounty(t.getConsigneeInfo().getCounty()); o.setTown(t.getConsigneeInfo().getTown());
            o.setAddress(t.getConsigneeInfo().getFullAddress());
            o.setReceiverName(t.getConsigneeInfo().getFullname());
            o.setReceiverPhone(t.getConsigneeInfo().getMobile());
        }
        List<ShopOrderItem> items = new ArrayList<>();
        if (t.getItemInfoList() != null) for (var it : t.getItemInfoList()) {
            ShopOrderItem i = new ShopOrderItem(); i.setOrderId(t.getOrderId());
            i.setProductId(it.getWareId()); i.setSkuId(it.getSkuId());
            i.setTitle(it.getSkuName()); i.setQuantity(it.getItemTotal() != null ? Integer.parseInt(it.getItemTotal()) : 0);
            i.setSalePrice(fen(it.getJdPrice())); i.setOuterSkuId(it.getOuterSkuId());
            i.setOrderTime(o.getOrderTime()); items.add(i);
        }
        o.setItems(items); o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private Integer jdStatus(String s) {
        if (s == null) return 21;
        return switch (s) {
            case "WAIT_SELLER_STOCK_OUT", "WAIT_SELLER_DELIVERY" -> 1;
            case "WAIT_GOODS_RECEIVE_CONFIRM" -> 2; case "TRADE_FINISHED" -> 3;
            case "TRADE_CANCELED" -> 11; case "LOCKED" -> 22; default -> 21;
        };
    }
    private ResultVo<String> pullJdOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 200); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = JdOrderApiHelper.pullOrderDetail(Long.parseLong(orderId), p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), jdOrder(r.getData()));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "JD detail:" + ex.getMessage(), begin); }
    }
    private ShopOrder jdOrder(JdOrderDetailResponse t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("JD"); o.setOrderId(t.getOrderId());
        o.setPlatformOrderStatus(t.getOrderState()); o.setOrderStatus(jdStatus(t.getOrderState()));
        o.setGoodsAmount(fen(t.getOrderTotalPrice())); o.setOrderAmount(fen(t.getOrderPayment()));
        o.setPaymentAmount(fen(t.getOrderPayment())); o.setFreight(fen(t.getFreightPrice()));
        o.setSellerDiscount(fen(t.getSellerDiscount()));
        o.setPaymentMethod(t.getPayType());
        o.setOrderTimeText(t.getOrderStartTime()); o.setUpdateTimeText(t.getModified());
        o.setOrderTime(ts(t.getOrderStartTime())); o.setUpdateTime(ts(t.getModified()));
        o.setPayTime(ts(t.getPaymentConfirmTime()));
        o.setRemark(t.getOrderRemark());
        if (t.getConsigneeInfo() != null) {
            o.setProvince(t.getConsigneeInfo().getProvince()); o.setCity(t.getConsigneeInfo().getCity());
            o.setCounty(t.getConsigneeInfo().getCounty()); o.setTown(t.getConsigneeInfo().getTown());
            o.setAddress(t.getConsigneeInfo().getFullAddress());
            o.setReceiverName(t.getConsigneeInfo().getFullname());
            o.setReceiverPhone(t.getConsigneeInfo().getMobile());
        }
        List<ShopOrderItem> items = new ArrayList<>();
        if (t.getItemInfoList() != null) for (var it : t.getItemInfoList()) {
            ShopOrderItem i = new ShopOrderItem(); i.setOrderId(t.getOrderId());
            i.setProductId(it.getWareId()); i.setSkuId(it.getSkuId());
            i.setTitle(it.getSkuName()); i.setQuantity(it.getItemTotal() != null ? Integer.parseInt(it.getItemTotal()) : 0);
            i.setSalePrice(fen(it.getJdPrice())); i.setOuterSkuId(it.getOuterSkuId());
            i.setOrderTime(o.getOrderTime()); items.add(i);
        }
        o.setItems(items); o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private ResultVo<String> pullJdRefund(OShop shop, long begin) {
        var p = chk(shop, 200); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusDays(1) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        String pp = "{st:" + st.format(DT) + "}";
        try {
            var r = JdAfterSaleApiHelper.pullAfterSaleList(Long.parseLong(p.getSellerId()), st, et, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (var rf : r.getList()) {
                try { ShopRefund sr = jdRefund(rf);
                    var rr = shopRefundService.saveRefund(shop.getId(), sr);
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { log.error("JD退款保存失败", ex); fail++; }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "JD:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullJdRefundDetail(OShop shop, String afterId, long begin) {
        var p = chk(shop, 200); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        try {
            var r = JdAfterSaleApiHelper.pullAfterSaleList(Long.parseLong(p.getSellerId()), null, null, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0 || r.getList() == null) return errLog(shop, "REFUND", r.getMsg(), "{afterId:" + afterId + "}", begin);
            // JD售后详情没有独立接口，通过列表按serviceId/applyId过滤
            AfterSale found = null;
            for (var rf : r.getList()) {
                if (rf.getServiceId() != null && afterId.equals(rf.getServiceId().toString())) { found = rf; break; }
                if (rf.getApplyId() != null && afterId.equals(rf.getApplyId().toString())) { found = rf; break; }
            }
            if (found == null) return ResultVo.error("未找到售后单");
            var rr = shopRefundService.saveRefund(shop.getId(), jdRefund(found));
            if (rr.getData() != null) oRefundService.shopRefundMessage(rr.getData());
            logMsg(shop, "REFUND", "{afterId:" + afterId + "}", "{}", begin);
            return ResultVo.success("售后[" + afterId + "]同步完成");
        } catch (Exception ex) { return err(shop, "REFUND", "JD detail:" + ex.getMessage(), begin); }
    }
    private ShopRefund jdRefund(AfterSale rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("JD");
        r.setAfterId(rf.getServiceId() != null ? rf.getServiceId().toString() : (rf.getApplyId() != null ? rf.getApplyId().toString() : null));
        r.setType(rf.getCustomerExpect()); r.setRefundStatus(rf.getApproveResult());
        r.setOrderId(rf.getOrderId() != null ? rf.getOrderId().toString() : null);
        r.setRefundAmount(fen(rf.getActualPayPrice()));
        r.setGoodsName(rf.getWareName()); r.setSkuId(rf.getSkuId() != null ? rf.getSkuId().toString() : null);
        r.setCreateTime(ts(rf.getApplyTime())); r.setUpdateTime(ts(rf.getUpdateDate()));
        r.setReturnDeliveryName(rf.getPickwareAddress());
        return r;
    }
    private ResultVo<String> pullJdGoods(OShop shop, long begin) {
        var p = chk(shop, 200); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = JdGoodsApiHelper.pullGoodsSkuList(p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getList() != null) for (var g : r.getList()) {
                try { ShopGoods sg = new ShopGoods(); sg.setProductId(g.getSkuId() != null ? g.getSkuId().toString() : null);
                    sg.setTitle(g.getSkuName()); sg.setImg(g.getLogo());
                    sg.setOuterProductId(g.getOuterId()); sg.setMinPrice(g.getJdPrice());
                    shopGoodsService.savePddGoods(sg, shop.getId()); success++;
                } catch (Exception ex) { log.error("JD商品保存失败", ex); }
            }
            logMsg(shop, "GOODS", "{}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "JD:" + ex.getMessage(), begin); }
    }


    // ======================== DOU 抖店 ========================

    private ResultVo<String> pullDouOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 400); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = DouOrderApiHelper.pullOrderList(s.toEpochSecond(ZoneOffset.ofHours(8)) * 1000, e.toEpochSecond(ZoneOffset.ofHours(8)) * 1000, 1, 100, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getList() != null) for (var order : r.getList()) {
                try { var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), douOrder(order));
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else upd++;
                } catch (Exception ex) { log.error("DOU订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "DOU:" + ex.getMessage(), begin); }
    }
    private ShopOrder douOrder(cn.qihangerp.open.dou.model.order.Order order) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("DOU");
        o.setOrderId(order.getOrderId());
        o.setOrderTime(order.getCreateTime() != null ? order.getCreateTime() / 1000 : null);
        o.setUpdateTime(order.getUpdateTime() != null ? order.getUpdateTime() / 1000 : null);
        o.setOrderStatus(order.getOrderStatus() != null ? order.getOrderStatus() : 0);
        o.setGoodsAmount(order.getOrderAmount() != null ? order.getOrderAmount().intValue() : 0);
        o.setOrderAmount(order.getOrderAmount() != null ? order.getOrderAmount().intValue() : 0);
        o.setFreight(order.getPostAmount() != null ? order.getPostAmount().intValue() : 0);
        o.setDiscountAmount(order.getPromotionAmount() != null ? order.getPromotionAmount().intValue() : 0);
        o.setPlatformDiscount(order.getPromotionPlatformAmount() != null ? order.getPromotionPlatformAmount().intValue() : 0);
        o.setSellerDiscount(order.getPromotionShopAmount() != null ? order.getPromotionShopAmount().intValue() : 0);
        o.setPayTime(order.getPayTime() != null ? order.getPayTime() / 1000 : null);
        o.setPaymentMethod(order.getPayType() != null ? String.valueOf(order.getPayType()) : null);
        o.setBuyerMemo(order.getUserNickName());
        o.setFinishTime(order.getFinishTime() != null ? order.getFinishTime() / 1000 : null);
        // 地址：PostAddrBean 的 province/city/town 是 TownBean 类型，取 name
        if (order.getPostAddr() != null) {
            var addr = order.getPostAddr();
            o.setProvince(addr.getProvince() != null ? addr.getProvince().getName() : null);
            o.setCity(addr.getCity() != null ? addr.getCity().getName() : null);
            o.setCounty(addr.getTown() != null ? addr.getTown().getName() : null);
            o.setAddress(addr.getDetail());
            o.setReceiverName(order.getPostReceiver());
            o.setReceiverPhone(order.getPostTel());
        }
        // 子订单
        List<ShopOrderItem> items = new ArrayList<>();
        if (order.getSkuOrderList() != null) for (var it : order.getSkuOrderList()) {
            ShopOrderItem i = new ShopOrderItem();
            i.setOrderId(order.getOrderId());
            i.setSubOrderId(it.getMasterSkuOrderId());
            i.setProductId(it.getProductIdStr());
            i.setSkuId(it.getSkuId() != null ? it.getSkuId().toString() : null);
            i.setTitle(it.getProductName());
            i.setImg(it.getProductPic());
            i.setQuantity(it.getItemNum());
            i.setSalePrice(it.getOrderAmount() != null && it.getItemNum() > 0 ? it.getOrderAmount() / it.getItemNum() : 0);
            i.setOuterSkuId(it.getOutSkuId());
            if (it.getSpec() != null && !it.getSpec().isEmpty()) {
                StringBuilder sb = new StringBuilder();
                for (var sp : it.getSpec()) { sb.append(sp.getName()).append(":").append(sp.getValue()).append(";"); }
                i.setSkuName(sb.toString());
            }
            i.setOrderTime(o.getOrderTime());
            items.add(i);
        }
        o.setItems(items); o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private ResultVo<String> pullDouOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 400); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = DouOrderApiHelper.pullOrderDetail(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), orderId);
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), douOrder(r.getData()));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "DOU detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullDouRefund(OShop shop, long begin) {
        var p = chk(shop, 400); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusDays(1) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        String pp = "{st:" + st.format(DT) + "}";
        try {
            var r = DouRefundApiHelper.pullAfterSaleList(st.toEpochSecond(ZoneOffset.ofHours(8)) * 1000, et.toEpochSecond(ZoneOffset.ofHours(8)) * 1000, 1, 100, p.getAppKey(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (var rf : r.getList()) {
                try { ShopRefund sr = douRefund(rf);
                    var rr = shopRefundService.saveRefund(shop.getId(), sr);
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { log.error("DOU退款保存失败", ex); fail++; }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "DOU:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullDouRefundDetail(OShop shop, String afterId, long begin) {
        // DOU售后详情可以通过pullAfterSaleList全量过滤（无独立详情接口）
        return pullDouRefund(shop, begin);
    }
    private ShopRefund douRefund(cn.qihangerp.open.dou.model.after.AfterSale rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("DOU");
        var af = rf.getAftersaleInfo();
        if (af != null) {
            r.setAfterId(af.getAftersaleId());
            r.setType(af.getAftersaleType());
            r.setStatus(af.getAftersaleStatus());
            r.setCount(af.getAftersaleNum());
            r.setRefundAmount(af.getRefundAmount() != null ? af.getRefundAmount() : 0);
            r.setCreateTime(af.getCreateTime() != null ? af.getCreateTime().longValue() : null);
            r.setUpdateTime(af.getUpdateTime() != null ? af.getUpdateTime().longValue() : null);
            r.setReturnWaybillId(af.getReturnLogisticsCode());
            r.setReturnDeliveryName(af.getReturnLogisticsCompanyName());
        }
        if (rf.getOrderInfo() != null) {
            r.setOrderId(rf.getOrderInfo().getShopOrderId());
            if (rf.getOrderInfo().getRelatedOrderInfo() != null && !rf.getOrderInfo().getRelatedOrderInfo().isEmpty()) {
                var ro = rf.getOrderInfo().getRelatedOrderInfo().get(0);
                r.setProductId(ro.getProductId() != null ? ro.getProductId().toString() : null);
                r.setGoodsName(ro.getProductName()); r.setGoodsImage(ro.getProductImage());
                r.setSkuId(ro.getShopSkuCode());
                r.setCount(ro.getAftersaleItemNum());
            }
        }
        r.setReason(rf.getTextPart() != null ? rf.getTextPart().getReasonText() : null);
        return r;
    }
    private ResultVo<String> pullDouGoods(OShop shop, long begin) {
        var p = chk(shop, 400); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = DouGoodsApiHelper.getGoodsList(p.getAppKey(), p.getAppSecret(), p.getAccessToken(), 1, 20);
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getData() != null && r.getData().getGoodsList() != null) for (var g : r.getData().getGoodsList()) {
                try { ShopGoods sg = douGoods(g);
                    shopGoodsService.savePddGoods(sg, shop.getId()); success++;
                } catch (Exception ex) { log.error("DOU商品保存失败", ex); }
            }
            logMsg(shop, "GOODS", "{}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "DOU:" + ex.getMessage(), begin); }
    }
    private ShopGoods douGoods(Goods g) {
        ShopGoods sg = new ShopGoods(); if (g == null) return sg;
        sg.setProductId(g.getProductId() != null ? g.getProductId().toString() : null);
        sg.setTitle(g.getName()); sg.setImg(g.getImg());
        sg.setOuterProductId(g.getOuterProductId());
        sg.setStatus(g.getStatus()); sg.setMinPrice(g.getDiscountPrice());
        sg.setMarketPrice(g.getMarketPrice());
        sg.setAddTime(g.getCreateTime() != null ? g.getCreateTime().longValue() : null);
        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (g.getSkuList() != null) for (var s : g.getSkuList()) {
            ShopGoodsSku sk = new ShopGoodsSku(); sk.setSkuId(s.getCode());
            sk.setOuterSkuId(s.getOutSkuId() != null ? s.getOutSkuId().toString() : null);
            sk.setPrice(s.getPrice()); sk.setStockNum(s.getStockNum());
            sk.setSkuName((s.getSpecDetailName1() != null ? s.getSpecDetailName1() : "")
                + (s.getSpecDetailName2() != null ? ";" + s.getSpecDetailName2() : "")
                + (s.getSpecDetailName3() != null ? ";" + s.getSpecDetailName3() : ""));
            sk.setStatus(s.isSkuStatus() ? 1 : 0);
            skuList.add(sk);
        }
        sg.setSkuList(skuList); return sg;
    }


    // ======================== WEI 微信小店 ========================

    private ResultVo<String> pullWeiOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 500); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = WeiOrderApiHelper.pullOrderList(s, e, p.getAccessToken(), 10, 0);
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getList() != null) for (var t : r.getList()) {
                try { var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), weiOrder(t));
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else upd++;
                } catch (Exception ex) { log.error("WEI订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "WEI:" + ex.getMessage(), begin); }
    }
    private ShopOrder weiOrder(Order t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("WEI");
        o.setOrderId(t.getOrder_id()); o.setOrderTime(t.getCreate_time()); o.setUpdateTime(t.getUpdate_time());
        o.setOrderStatus(weiStatus(t.getStatus()));
        var d = t.getOrder_detail();
        if (d != null) {
            if (d.getPrice_info() != null) {
                JSONObject price = d.getPrice_info();
                o.setGoodsAmount(price.getIntValue("total_product_price"));
                o.setOrderAmount(price.getIntValue("order_original_price"));
                o.setFreight(price.getIntValue("freight"));
                o.setDiscountAmount(price.getIntValue("discounted_price"));
                o.setPaymentAmount(price.getIntValue("order_payment"));
            }
            if (d.getPay_info() != null) {
                JSONObject pay = d.getPay_info();
                o.setPayTime(ts(pay.getString("pay_time")));
                o.setPaymentMethod(pay.getString("pay_method"));
            }
            if (d.getDelivery_info() != null) {
                var addr = d.getDelivery_info().getAddress_info();
                if (addr != null) { o.setProvince(addr.getProvince_name()); o.setCity(addr.getCity_name()); o.setCounty(addr.getCounty_name()); }
                o.setReceiverName(d.getDelivery_info().getAddress_info() != null ? d.getDelivery_info().getAddress_info().getUser_name() : null);
                o.setReceiverPhone(d.getDelivery_info().getAddress_info() != null ? d.getDelivery_info().getAddress_info().getTel_number() : null);
                o.setAddress(d.getDelivery_info().getAddress_info() != null ? d.getDelivery_info().getAddress_info().getDetail_info() : null);
            }
            List<ShopOrderItem> items = new ArrayList<>();
            if (d.getProduct_infos() != null) for (var p : d.getProduct_infos()) {
                ShopOrderItem i = new ShopOrderItem(); i.setOrderId(t.getOrder_id());
                i.setProductId(p.getProduct_id()); i.setSkuId(p.getSku_id());
                i.setTitle(p.getTitle()); i.setImg(p.getThumb_img()); i.setQuantity(p.getSku_cnt());
                i.setSalePrice(p.getSale_price() != null ? p.getSale_price() : 0);
                i.setMarketPrice(p.getMarket_price() != null ? p.getMarket_price() : 0);
                i.setRealPrice(p.getReal_price() != null ? p.getReal_price() : 0);
                i.setOuterProductId(p.getOut_product_id()); i.setOuterSkuId(p.getOut_sku_id());
                i.setOrderTime(o.getOrderTime()); items.add(i);
            }
            o.setItems(items);
        }
        o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private Integer weiStatus(Integer s) {
        if (s == null) return 21;
        return switch (s) { case 10 -> 21; case 20, 21 -> 1; case 22 -> 101; case 30 -> 2; case 100 -> 3; case 200 -> 11; case 250 -> 12; default -> s; };
    }
    private ResultVo<String> pullWeiOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 500); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = WeiOrderApiHelper.pullOrderDetail(Long.parseLong(orderId), p.getAccessToken());
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), weiOrder(r.getData()));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "WEI detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullWeiRefund(OShop shop, long begin) {
        var p = chk(shop, 500); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusDays(1) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        if (st.plusHours(24).isBefore(et)) et = st.plusHours(24); // WEI限制24h
        String pp = "{st:" + st.format(DT) + ",et:" + et.format(DT) + "}";
        try {
            var r = WeiRefundApiHelper.pullRefundList(st, et, p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (var rf : r.getList()) {
                try { var rr = shopRefundService.saveRefund(shop.getId(), weiRefund(rf));
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { log.error("WEI退款保存失败", ex); fail++; }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "WEI:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullWeiRefundDetail(OShop shop, String afterId, long begin) {
        var p = chk(shop, 500); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        try {
            var r = WeiRefundApiHelper.pullRefundDetail(Long.parseLong(afterId), p.getAccessToken());
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "REFUND", r.getMsg(), "{afterId:" + afterId + "}", begin);
            var rr = shopRefundService.saveRefund(shop.getId(), weiRefund(r.getData()));
            if (rr.getData() != null) oRefundService.shopRefundMessage(rr.getData());
            logMsg(shop, "REFUND", "{afterId:" + afterId + "}", "{}", begin);
            return ResultVo.success("售后[" + afterId + "]同步完成");
        } catch (Exception ex) { return err(shop, "REFUND", "WEI detail:" + ex.getMessage(), begin); }
    }
    private ShopRefund weiRefund(AfterSaleOrder rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("WEI");
        r.setAfterId(rf.getAfter_sale_order_id());
        r.setOrderId(rf.getOrder_id());
        r.setType("RETURN".equals(rf.getType()) ? 10 : 11);
        r.setStatus(weiRefundStatus(rf.getStatus()));
        if (rf.getProduct_info() != null) {
            r.setProductId(rf.getProduct_info().getProduct_id());
            r.setSkuId(rf.getProduct_info().getSku_id());
            r.setCount(rf.getProduct_info().getCount());
        }
        if (rf.getRefund_info() != null) {
            r.setRefundAmount(rf.getRefund_info().getIntValue("amount"));
            r.setReason(rf.getRefund_info().getString("reason_text"));
        }
        if (rf.getReturn_info() != null) {
            r.setReturnWaybillId(rf.getReturn_info().getWaybill_id());
            r.setReturnDeliveryId(rf.getReturn_info().getDelivery_id());
            r.setReturnDeliveryName(rf.getReturn_info().getDelivery_name());
        }
        r.setReason(rf.getReason_text());
        r.setCreateTime(rf.getCreate_time() != null ? rf.getCreate_time().longValue() : null);
        r.setUpdateTime(rf.getUpdate_time() != null ? rf.getUpdate_time().longValue() : null);
        return r;
    }
    private Integer weiRefundStatus(String s) {
        if (s == null) return 1;
        return switch (s) {
            case "WAIT_SELLER_ACCEPT" -> 2; case "SELLER_ACCEPT_REFUND", "WAIT_SELLER_RECEIVE" -> 3;
            case "REFUND_SUCCESS" -> 4; case "REFUND_CLOSE", "SELLER_REFUSE_REFUND" -> 1;
            default -> 1;
        };
    }
    private ResultVo<String> pullWeiGoods(OShop shop, long begin) {
        var p = chk(shop, 500); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = WeiGoodsApiHelper.pullGoodsList(p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getList() != null) for (var g : r.getList()) {
                try { shopGoodsService.savePddGoods(weiGoods(g), shop.getId()); success++; } catch (Exception ex) { log.error("WEI商品保存失败", ex); }
            }
            logMsg(shop, "GOODS", "{}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "WEI:" + ex.getMessage(), begin); }
    }
    private ShopGoods weiGoods(Product g) {
        ShopGoods sg = new ShopGoods(); if (g == null) return sg;
        sg.setProductId(g.getProduct_id()); sg.setOuterProductId(g.getOut_product_id());
        sg.setTitle(g.getTitle()); sg.setSubTitle(g.getSub_title());
        sg.setMinPrice(g.getMin_price()); sg.setStatus(g.getStatus());
        sg.setSpuCode(g.getSpu_code());
        if (g.getHead_imgs() != null && !g.getHead_imgs().isEmpty()) {
            sg.setImg(g.getHead_imgs().getString(0));
            sg.setImgs(g.getHead_imgs().toJSONString());
        }
        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (g.getSkus() != null) for (var s : g.getSkus()) {
            ShopGoodsSku sk = new ShopGoodsSku(); sk.setSkuId(s.getSku_id());
            sk.setOuterSkuId(s.getOut_sku_id()); sk.setImg(s.getThumb_img());
            sk.setPrice(s.getSale_price()); sk.setStockNum(s.getStock_num());
            sk.setStatus(s.getStatus()); sk.setSkuCode(s.getSku_code());
            if (s.getSku_attrs() != null && !s.getSku_attrs().isEmpty()) {
                sk.setSkuName(s.getSku_attrs().toJSONString());
            }
            skuList.add(sk);
        }
        sg.setSkuList(skuList); return sg;
    }


    // ======================== KWAI 快手 ========================

    private ResultVo<String> pullKwaiOrder(OShop shop, String startTime, String endTime, long begin) {
        var p = chk(shop, 600); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        LocalDateTime s = LocalDateTime.parse(startTime + " 00:00:01", DT);
        LocalDateTime e = StringUtils.hasText(endTime) ? LocalDateTime.parse(endTime + " 23:59:59", DT) : LocalDateTime.parse(startTime + " 23:59:59", DT);
        long stMs = s.toEpochSecond(ZoneOffset.ofHours(8)) * 1000;
        long etMs = e.toEpochSecond(ZoneOffset.ofHours(8)) * 1000;
        String pp = "{st:" + s.format(DT) + "}";
        try {
            var r = KwaiOrderApiHelper.pullOrderList(p.getAppKey(), p.getAppSecret(), p.getAppSecret(), p.getAccessToken(), stMs, etMs);
            if (r.getCode() != 0) return errLog(shop, "ORDER", r.getMsg(), pp, begin);
            int ins = 0, upd = 0, fail = 0;
            if (r.getList() != null) for (var t : r.getList()) {
                try { ShopOrder o = kwaiOrder(t);
                    var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), o);
                    if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
                    if (sr.getCode() == 0) ins++; else upd++;
                } catch (Exception ex) { log.error("KWAI订单保存失败", ex); fail++; }
            }
            logMsg(shop, "ORDER", pp, "{ins:" + ins + ",upd:" + upd + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "，更新" + upd + "，失败" + fail);
        } catch (Exception ex) { return err(shop, "ORDER", "KWAI:" + ex.getMessage(), begin); }
    }
    private ShopOrder kwaiOrder(JSONObject t) {
        ShopOrder o = new ShopOrder(); o.setPlatformType("KWAI");
        o.setOrderId(t.getString("orderId"));
        o.setOrderTime(t.getLong("createTime") != null ? t.getLong("createTime") / 1000 : null);
        o.setUpdateTime(t.getLong("updateTime") != null ? t.getLong("updateTime") / 1000 : null);
        o.setOrderStatus(t.getIntValue("orderStatus") != 0 ? t.getIntValue("orderStatus") : 1);
        // 订单金额(分)
        JSONObject orderDetail = t.getJSONObject("orderDetail");
        if (orderDetail != null) {
            o.setOrderAmount(orderDetail.getIntValue("payAmount"));
            o.setPaymentAmount(orderDetail.getIntValue("payAmount"));
            o.setGoodsAmount(orderDetail.getIntValue("productAmount"));
            o.setFreight(orderDetail.getIntValue("freightAmount"));
            o.setDiscountAmount(orderDetail.getIntValue("discountAmount"));
            o.setPayTime(orderDetail.getLong("payTime") != null ? orderDetail.getLong("payTime") / 1000 : null);
        }
        // 收货地址
        JSONObject receiver = t.getJSONObject("receiverInfo");
        if (receiver != null) {
            o.setProvince(receiver.getString("provinceName")); o.setCity(receiver.getString("cityName"));
            o.setCounty(receiver.getString("townName")); o.setAddress(receiver.getString("detailAddress"));
            o.setReceiverName(receiver.getString("userName")); o.setReceiverPhone(receiver.getString("mobile"));
        }
        // 商品明细(快手返回的itemList)
        JSONArray itemList = t.getJSONArray("itemList");
        List<ShopOrderItem> items = new ArrayList<>();
        if (itemList != null) for (int i = 0; i < itemList.size(); i++) {
            JSONObject it = itemList.getJSONObject(i);
            ShopOrderItem si = new ShopOrderItem(); si.setOrderId(t.getString("orderId"));
            si.setProductId(it.getString("productId")); si.setSkuId(it.getString("skuId"));
            si.setTitle(it.getString("name")); si.setImg(it.getString("pictureUrl"));
            si.setQuantity(it.getIntValue("count")); si.setSalePrice(it.getIntValue("price") / (it.getIntValue("count") > 0 ? it.getIntValue("count") : 1));
            si.setOrderTime(o.getOrderTime()); items.add(si);
        }
        o.setItems(items);
        o.setOrderType(0); o.setOrderMode(0); o.setErpShipStatus(0); o.setConfirmStatus(0);
        return o;
    }
    private ResultVo<String> pullKwaiOrderDetail(OShop shop, String orderId, long begin) {
        var p = chk(shop, 600); if (p == null) return err(shop, "ORDER", "校验失败", begin);
        try {
            var r = KwaiOrderApiHelper.pullOrderDetail(p.getAppKey(), p.getAppSecret(), p.getAppSecret(), p.getAccessToken(), orderId);
            if (r.getCode() != 0 || r.getData() == null) return errLog(shop, "ORDER", r.getMsg(), "{orderId:" + orderId + "}", begin);
            var sr = shopOrderService.saveOrder(shop.getId(), shop.getMerchantId(), shop.getType(), kwaiOrder(r.getData()));
            if (sr.getData() != null && sr.getData() > 0) oOrderService.shopOrderMessage(sr.getData());
            logMsg(shop, "ORDER", "{orderId:" + orderId + "}", "{}", begin);
            return ResultVo.success("订单[" + orderId + "]同步完成");
        } catch (Exception ex) { return err(shop, "ORDER", "KWAI detail:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullKwaiRefund(OShop shop, long begin) {
        var p = chk(shop, 600); if (p == null) return err(shop, "REFUND", "校验失败", begin);
        var lt = pullLasttimeService.getLasttimeByShop(shop.getId(), "REFUND");
        LocalDateTime st = lt == null ? LocalDateTime.now().minusDays(7) : lt.getLasttime().minusMinutes(5);
        LocalDateTime et = LocalDateTime.now();
        long stMs = st.toEpochSecond(ZoneOffset.ofHours(8)) * 1000;
        long etMs = et.toEpochSecond(ZoneOffset.ofHours(8)) * 1000;
        String pp = "{st:" + st.format(DT) + "}";
        try {
            var r = KwaiRefundApiHelper.pullRefundList(p.getAppKey(), p.getAppSecret(), p.getAppSecret(), p.getAccessToken(), stMs, etMs);
            if (r.getCode() != 0) return errLog(shop, "REFUND", r.getMsg(), pp, begin);
            int ins = 0, fail = 0;
            if (r.getList() != null) for (var rf : r.getList()) {
                try { var rr = shopRefundService.saveRefund(shop.getId(), kwaiRefund(rf));
                    if (rr.getData() != null) { oRefundService.shopRefundMessage(rr.getData()); ins++; } else fail++;
                } catch (Exception ex) { log.error("KWAI退款保存失败", ex); fail++; }
            }
            if (fail == 0) upsertLt(shop.getId(), "REFUND", et, lt);
            logMsg(shop, "REFUND", pp, "{ins:" + ins + ",fail:" + fail + "}", begin);
            return ResultVo.success("成功，新增" + ins + "条");
        } catch (Exception ex) { return err(shop, "REFUND", "KWAI:" + ex.getMessage(), begin); }
    }
    private ResultVo<String> pullKwaiRefundDetail(OShop shop, String afterId, long begin) {
        return pullKwaiRefund(shop, begin);
    }
    private ShopRefund kwaiRefund(JSONObject rf) {
        ShopRefund r = new ShopRefund(); r.setPlatformType("KWAI");
        r.setAfterId(rf.getString("refundId") != null ? rf.getString("refundId") : rf.getString("id"));
        r.setOrderId(rf.getString("orderId"));
        r.setType(rf.getIntValue("refundType"));
        r.setStatus(rf.getIntValue("refundStatus"));
        r.setRefundAmount(rf.getIntValue("refundAmount"));
        r.setReason(rf.getString("reason"));
        r.setCreateTime(rf.getLong("createTime") != null ? rf.getLong("createTime") / 1000 : null);
        r.setUpdateTime(rf.getLong("updateTime") != null ? rf.getLong("updateTime") / 1000 : null);
        JSONObject itemInfo = rf.getJSONObject("itemInfo");
        if (itemInfo != null) {
            r.setProductId(itemInfo.getString("productId"));
            r.setGoodsName(itemInfo.getString("productName"));
            r.setSkuId(itemInfo.getString("skuId"));
            r.setCount(itemInfo.getIntValue("count"));
            r.setGoodsPrice(itemInfo.getIntValue("price"));
        }
        return r;
    }
    private ResultVo<String> pullKwaiGoods(OShop shop, long begin) {
        var p = chk(shop, 600); if (p == null) return err(shop, "GOODS", "校验失败", begin);
        try {
            var r = KwaiGoodsApiHelper.pullGoodsAll(p.getAppKey(), p.getAppSecret(), p.getAppSecret(), p.getAccessToken());
            if (r.getCode() != 0) return errLog(shop, "GOODS", r.getMsg(), "{}", begin);
            int success = 0;
            if (r.getList() != null) for (var g : r.getList()) {
                try { shopGoodsService.savePddGoods(kwaiGoods(g), shop.getId()); success++; } catch (Exception ex) { log.error("KWAI商品保存失败", ex); }
            }
            logMsg(shop, "GOODS", "{}", "{success:" + success + "}", begin);
            return ResultVo.success("拉取成功" + success + "件");
        } catch (Exception ex) { return err(shop, "GOODS", "KWAI:" + ex.getMessage(), begin); }
    }
    private ShopGoods kwaiGoods(KwaiGoodsItem g) {
        ShopGoods sg = new ShopGoods(); if (g == null) return sg;
        sg.setProductId(g.getKwaiItemId() != null ? g.getKwaiItemId().toString() : null);
        sg.setTitle(g.getTitle()); sg.setImg(g.getMainImageUrl());
        sg.setOuterProductId(g.getRelItemId() != null ? g.getRelItemId().toString() : null);
        sg.setStatus(g.getShelfStatus()); sg.setMinPrice(g.getPrice());
        sg.setAddTime(g.getCreateTime());
        List<ShopGoodsSku> skuList = new ArrayList<>();
        if (g.getSkuList() != null) for (var s : g.getSkuList()) {
            ShopGoodsSku sk = new ShopGoodsSku();
            sk.setSkuId(s.getKwaiSkuId() != null ? s.getKwaiSkuId().toString() : null);
            sk.setOuterSkuId(s.getRelSkuId() != null ? s.getRelSkuId().toString() : null);
            sk.setPrice(s.getSkuSalePrice()); sk.setStockNum(s.getSkuStock());
            sk.setSkuName(s.getSkuNick()); sk.setImg(s.getImageUrl());
            skuList.add(sk);
        }
        sg.setSkuList(skuList); return sg;
    }

    // ======================== 工具 ========================

    private OShop getShop(Long shopId) { if (shopId == null || shopId <= 0) return null; return shopService.getById(shopId); }
    private ShopApiParams chk(OShop shop, int expectedType) { return shopApiCommon.checkBefore(shop.getId(), expectedType).getData(); }
    private Integer fen(String s) { if (!StringUtils.hasText(s)) return 0; try { return (int) Math.round(Double.parseDouble(s) * 100); } catch (Exception e) { return 0; } }
    private Integer fen(Double d) { return d == null ? 0 : (int) Math.round(d * 100); }
    private Integer fen(double d) { return (int) Math.round(d * 100); }
    private Long ts(String time) {
        if (!StringUtils.hasText(time)) return null;
        try { return LocalDateTime.parse(time, DT).toEpochSecond(ZoneOffset.ofHours(8)); } catch (DateTimeParseException ignored) {}
        try { return Instant.parse(time).getEpochSecond(); } catch (Exception ignored) {}
        return null;
    }
    private void logMsg(OShop shop, String type, String params, String result, long begin) {
        try { OShopPullLogs l = new OShopPullLogs(); l.setShopId(shop.getId()); l.setMerchantId(shop.getMerchantId()); l.setShopType(shop.getType());
            l.setPullType(type); l.setPullWay("拉取"); l.setPullParams(params); l.setPullResult(result);
            l.setPullTime(LocalDateTime.now()); l.setDuration(System.currentTimeMillis() - begin); pullLogsService.save(l);
        } catch (Exception e) { log.error("保存拉取日志失败", e); }
    }
    private ResultVo<String> err(OShop shop, String type, String msg, long begin) { logMsg(shop, type, "{}", "error:" + msg, begin); return ResultVo.error(msg); }
    private ResultVo<String> errLog(OShop shop, String type, String msg, String pParams, long begin) { logMsg(shop, type, pParams, "error:" + msg, begin); return ResultVo.error(msg); }
    private void upsertLt(Long shopId, String pullType, LocalDateTime lasttime, OShopPullLasttime exist) {
        try { if (exist == null) { OShopPullLasttime ins = new OShopPullLasttime(); ins.setShopId(shopId); ins.setPullType(pullType);
            ins.setLasttime(lasttime); ins.setCreateTime(LocalDateTime.now()); pullLasttimeService.save(ins);
        } else { OShopPullLasttime up = new OShopPullLasttime(); up.setId(exist.getId()); up.setLasttime(lasttime);
            up.setUpdateTime(LocalDateTime.now()); pullLasttimeService.updateById(up); }
        } catch (Exception e) { log.error("更新最后拉取时间失败", e); }
    }
}