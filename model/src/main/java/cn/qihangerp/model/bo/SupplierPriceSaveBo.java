package cn.qihangerp.model.bo;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 保存供应商报价BO
 */
@Data
public class SupplierPriceSaveBo implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long supplierId;
    private List<SkuPriceItem> skus;

    @Data
    public static class SkuPriceItem implements Serializable {
        private static final long serialVersionUID = 1L;

        /** 供应商SKU item ID（优先） */
        private Long skuItemId;

        /** 商品库SKU ID（备用） */
        private Long erpSkuId;

        /** 报价价格 */
        private BigDecimal price;
    }
}
