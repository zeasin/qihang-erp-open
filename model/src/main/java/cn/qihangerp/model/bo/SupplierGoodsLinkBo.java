package cn.qihangerp.model.bo;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 供应商商品库关联BO
 * 从商品库选择商品并关联到供应商
 */
@Data
public class SupplierGoodsLinkBo implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 供应商ID */
    private Long supplierId;

    /** 商品库SPU ID */
    private Long goodsId;

    /** SKU列表 */
    private List<SkuItem> skus;

    @Data
    public static class SkuItem implements Serializable {
        private static final long serialVersionUID = 1L;

        /** 商品库SKU ID */
        private Long skuId;

        /** 供应商价格 */
        private BigDecimal price;

        /** SKU编码（可选，用于展示） */
        private String skuCode;

        /** SKU名称（可选，用于展示） */
        private String skuName;
    }
}
