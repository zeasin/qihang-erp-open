package cn.qihangerp.erp.service;

import cn.qihangerp.common.ResultVo;

/**
 * OMS 统一拉取服务：<br>
 * 根据 shopType 路由到各电商平台 SDK（目前实现 PDD 分支，其它平台可后续按相同模式补充）。<br>
 * 拉取到的原始数据统一转换为 {@link cn.qihangerp.model.entity.ShopOrder}/{@link
 * cn.qihangerp.model.entity.ShopGoods}/{@link cn.qihangerp.model.entity.ShopRefund}，
 * 保存到统一表（oms_shop_*），并可通过 pushOms 同步到 o_order / o_refund。
 */
public interface ShopPullApiService {

    /**
     * 增量拉取店铺订单列表（按下单日期），保存到 oms_shop_order。
     *
     * @param shopId    店铺id
     * @param startTime 起始日期 yyyy-MM-dd
     * @param endTime   结束日期 yyyy-MM-dd（与 startTime 同一天）
     * @return 拉取结果描述
     */
    ResultVo<String> pullOrder(Long shopId, String startTime, String endTime);

    /**
     * 拉取单个订单详情，保存/更新到 oms_shop_order。
     *
     * @param shopId  店铺id
     * @param orderId 平台订单号
     */
    ResultVo<String> pullOrderDetail(Long shopId, String orderId);

    /**
     * 增量拉取店铺售后列表，保存到 oms_shop_refund。
     *
     * @param shopId 店铺id
     */
    ResultVo<String> pullRefund(Long shopId);

    /**
     * 拉取单个售后详情，保存/更新到 oms_shop_refund。
     *
     * @param shopId   店铺id
     * @param afterId  平台售后单号
     */
    ResultVo<String> pullRefundDetail(Long shopId, String afterId);

    /**
     * 拉取店铺商品列表（含SKU），保存到 oms_shop_goods / oms_shop_goods_sku。
     *
     * @param shopId   店铺id
     * @param pullType 0全量/1增量（按更新时间）
     */
    ResultVo<String> pullGoods(Long shopId, Integer pullType);
}
