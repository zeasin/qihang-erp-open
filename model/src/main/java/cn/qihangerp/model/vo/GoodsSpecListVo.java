package cn.qihangerp.model.vo;


import lombok.Data;

import java.math.BigDecimal;
@Data
public class GoodsSpecListVo {

    private String skuId;
    private Integer priceType;
    private Long goodsId;

    /** 商品名称 */
    private String goodsName;
    private String skuName;

    /** 商品编号 */
    private String outerErpSkuId;
    private String skuCode;
    private String colorValue;
    /** 商品图片地址 */
    private String colorImage;
    private String sizeValue;
    private String styleValue;
    private BigDecimal retailPrice;
    private BigDecimal purPrice;

    /** 供应商报价（当传入supplierId时返回） */
    private BigDecimal supplierPrice;

}
