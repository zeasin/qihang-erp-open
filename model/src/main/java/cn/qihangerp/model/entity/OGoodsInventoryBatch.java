package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 主系统商品库存批次明细
 * 对应表 o_goods_inventory_batch
 * 区别于多仓库子系统的 erp_warehouse_goods_stock_batch
 */
@Data
@TableName("o_goods_inventory_batch")
public class OGoodsInventoryBatch {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 库存主键id（关联o_goods_inventory.id） */
    private Long inventoryId;

    /** 批次号 */
    private String batchNum;

    /** 初始数量 */
    private Integer originQty;

    /** 当前数量 */
    private Integer currentQty;

    /** 采购单价 */
    private BigDecimal purPrice;

    /** 采购单id */
    private Long purId;

    /** 采购单itemId */
    private Long purItemId;

    /** 备注 */
    private String remark;

    /** 规格id */
    private Long skuId;

    /** 商品id */
    private Long goodsId;

    /** sku编码 */
    private String skuCode;

    /** 仓库id */
    private Long warehouseId;

    /** 仓位id */
    private Long positionId;

    /** 仓位编码 */
    private String positionNum;

    /** 商户ID */
    private Long merchantId;

    /** 店铺ID */
    private Long shopId;

    /** 条码（一物一码模式使用） */
    private String barcode;

    /** 库存状态：1-良品 2-残品 */
    private Integer stockStatus;

    /** 库存模式：0-传统SKU模式 1-一物一码模式（珠宝） */
    private Integer inventoryMode;

    /** 实际金重（克） */
    private BigDecimal actualGoldWeight;

    /** 实际银重（克） */
    private BigDecimal actualSilverWeight;

    /** 工费（元） */
    private BigDecimal laborCost;

    /** 鉴定证书号 */
    private String certificateNo;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 创建人 */
    private String createBy;

    /** 更新时间 */
    private LocalDateTime updateTime;

    /** 更新人 */
    private String updateBy;
}