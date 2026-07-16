package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.bo.SupplierProductAddBo;
import cn.qihangerp.model.bo.SupplierGoodsLinkBo;
import cn.qihangerp.model.entity.ErpSupplierProduct;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.ErpSupplierProductService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 供应商商品管理 - SPU维度
 */
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/supplier/goods")
public class SupplierGoodsController extends BaseController {

    private final ErpSupplierProductService supplierProductService;

    /**
     * 分页查询供应商商品列表
     */
    @GetMapping("/list")
    public TableDataInfo list(ErpSupplierProduct query, PageQuery pageQuery) {
        var pageList = supplierProductService.queryPageList(query, pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 获取供应商商品详情（含SKU列表）
     */
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        ErpSupplierProduct product = supplierProductService.getById(id);
        if (product == null) {
            return error("供应商商品不存在");
        }
        product.setSkuList(supplierProductService.queryItemListByProductId(id));
        return success(product);
    }

    /**
     * 新增供应商商品（含SKU列表）
     */
    @PostMapping("/add")
    public AjaxResult add(@RequestBody SupplierProductAddBo bo) {
        var result = supplierProductService.addProduct(getUsername(), bo);
        return result.getCode() == 200 ? success(result.getData()) : error(result.getMsg());
    }

    /**
     * 修改供应商商品（含SKU列表）
     */
    @PutMapping("/edit")
    public AjaxResult edit(@RequestBody SupplierProductAddBo bo) {
        var result = supplierProductService.updateProduct(getUsername(), bo);
        return result.getCode() == 200 ? success() : error(result.getMsg());
    }

    /**
     * 删除供应商商品
     */
    @DeleteMapping("/del/{id}")
    public AjaxResult remove(@PathVariable Long id) {
        supplierProductService.deleteProduct(id);
        return success();
    }

    /**
     * 修改供应商商品状态（审核/下架）
     */
    @PutMapping("/status")
    public AjaxResult updateStatus(@RequestBody ErpSupplierProduct bo) {
        supplierProductService.updateStatus(bo.getId(), bo.getStatus());
        return success();
    }

    /**
     * 从商品库关联商品到供应商
     * 支持批量添加SKU，已存在的SKU自动更新价格
     * @param bo {supplierId, goodsId, skus:[{skuId, price, skuCode, skuName}]}
     */
    @PostMapping("/link")
    public AjaxResult linkGoods(@RequestBody SupplierGoodsLinkBo bo) {
        var result = supplierProductService.linkGoodsFromLibrary(getUsername(), bo);
        return result.getCode() == 0 ? success() : error(result.getMsg());
    }
}
