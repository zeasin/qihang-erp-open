package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 供应商商品表(SPU维度)
 * @TableName erp_supplier_product
 */
@TableName(value ="erp_supplier_product")
@Data
public class ErpSupplierProduct {
    /**
     * 主键id
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 供应商ID
     */
    private Long supplierId;

    /**
     * 商品名称
     */
    private String productName;

    /**
     * 商品图片地址
     */
    private String imageUrl;

    /**
     * 商品编号
     */
    private String productNum;

    /**
     * 商品分类ID
     */
    private Long categoryId;

    /**
     * 品牌ID
     */
    private Long brandId;

    /**
     * 单位名称
     */
    private String unitName;

    /**
     * 长 (毫米)
     */
    private Double length;

    /**
     * 宽 (毫米)
     */
    private Double width;

    /**
     * 高 (毫米)
     */
    private Double height;

    /**
     * 重量 (千克)
     */
    private Double weight;

    /**
     * 状态(0待审核1已审核2下架)
     */
    private Integer status;

    /**
     * 商品库SPU ID(o_goods外键)
     */
    private Long erpGoodsId;

    /**
     * 所属商户0总部，大于0就是商户
     */
    private Long merchantId;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建人
     */
    private String createBy;

    /**
     * 创建时间
     */
    private LocalDateTime createTime;

    /**
     * 更新人
     */
    private String updateBy;

    /**
     * 更新时间
     */
    private LocalDateTime updateTime;

    /**
     * SKU数量（非数据库字段，用于列表展示）
     */
    @TableField(exist = false)
    private Integer skuCount;

    /**
     * 供应商名称（非数据库字段）
     */
    @TableField(exist = false)
    private String supplierName;

    /**
     * SKU列表（非数据库字段，用于详情展示）
     */
    @TableField(exist = false)
    private List<ErpSupplierProductItem> skuList;
}