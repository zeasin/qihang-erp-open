package cn.qihangerp.request;

import lombok.Data;

/**
 * 统一发货记录查询请求
 * 根据 type 区分发货人类型：
 *   0  - 本地仓
 *   300 - 供应商
 *   100/110/200 - 云仓
 */
@Data
public class ShipRecordQueryRequest {

    /** 页码 */
    private Integer pageNum = 1;
    /** 每页条数 */
    private Integer pageSize = 10;

    /** 发货人类型：0本地仓 300供应商 100京东云仓 110吉客云 200系统云仓 */
    private Integer type;
    /** 发货人ID（本地仓=0,供应商ID,云仓ID） */
    private Long shipperId;
    /** 订单编号 */
    private String orderNum;
    /** 快递单号 */
    private String waybillCode;
    /** 店铺ID */
    private Long shopId;
    /** 店铺类型 */
    private Integer shopType;
    /** 发货状态 0待发货 1部分发货 2全部发货 */
    private Integer sendStatus;
    /** 面单状态 0未取号 1已取号 2已打印 3已发货 */
    private Integer waybillStatus;
    /** 推送状态 0待推送 1已推送（云仓） */
    private Integer erpPushStatus;
    /** 开始时间 */
    private String startTime;
    /** 结束时间 */
    private String endTime;
    /** 云仓发货单号 */
    private String shippingErpOrderCode;
    /** 京东云仓单号 */
    private String shippingOrderCode;
    /** 商户ID */
    private Long merchantId;
    /** 仓库ID */
    private Long warehouseId;
    /** 供应商ID（供应商发货用） */
    private Long supplierId;
    /** 订单状态 */
    private Integer orderStatus;
    /** 库存状态 0待备货 1备货中 2备货完成 */
    private Integer stockingStatus;
    /** 查询全部云仓发货（当type为空时，此标记为true则查全部云仓 type>=100 && <=200） */
    private Boolean allCloud;
}
