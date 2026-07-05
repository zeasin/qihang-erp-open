package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 主系统商品库存（SKU + 仓库维度）
 * 对应表 o_goods_inventory
 * 区别于多仓库子系统的 erp_warehouse_goods_stock，此表是主系统自有库存
 */
@Data
@TableName("o_goods_inventory")
public class OGoodsInventory {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 商品库商品id */
    private Long goodsId;

    /** 商品编码 */
    private String goodsNum;

    /** 商品库商品规格id */
    private Long skuId;

    /** 规格编码（唯一） */
    private String skuCode;

    /** 商品名 */
    private String goodsName;

    /** 商品图片 */
    private String goodsImg;

    /** SKU名 */
    private String skuName;

    /** 当前库存（总库存） */
    private Integer quantity;

    /** 锁定库存 */
    private Integer lockedQuantity;

    /** 可用库存（quantity - locked_quantity） */
    private Integer availableQuantity;

    /** 对应的仓库id */
    private Long warehouseId;

    /** 商户ID（多租户） */
    private Long merchantId;

    /** 店铺ID（0代表商户自营） */
    private Long shopId;

    /** 库存状态：1-良品 2-残品 */
    private Integer stockStatus;

    /** 0正常 1删除 */
    private Integer isDelete;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 创建人 */
    private String createBy;

    /** 更新时间 */
    private LocalDateTime updateTime;

    /** 更新人 */
    private String updateBy;
}