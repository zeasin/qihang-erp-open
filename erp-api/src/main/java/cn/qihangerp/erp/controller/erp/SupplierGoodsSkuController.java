package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.entity.ErpSupplierGoodsPrice;
import cn.qihangerp.model.entity.ErpSupplierProductItem;
import cn.qihangerp.mapper.ErpSupplierGoodsPriceMapper;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.ErpSupplierProductItemService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 供应商商品管理 - SKU维度
 */
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/supplier/goods_sku")
public class SupplierGoodsSkuController extends BaseController {

    private final ErpSupplierProductItemService supplierProductItemService;
    private final ErpSupplierGoodsPriceMapper supplierGoodsPriceMapper;

    /**
     * 分页查询供应商商品SKU列表
     */
    @GetMapping("/list")
    public TableDataInfo list(ErpSupplierProductItem query, PageQuery pageQuery) {
        var pageList = supplierProductItemService.queryPageList(query, pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 获取供应商商品SKU详情
     */
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        return success(supplierProductItemService.getById(id));
    }

    /**
     * 修改供应商商品SKU
     */
    @PutMapping("/edit")
    public AjaxResult edit(@RequestBody ErpSupplierProductItem item) {
        return toAjax(supplierProductItemService.updateById(item));
    }

    /**
     * 删除供应商商品SKU（同时删除关联的报价记录）
     */
    @DeleteMapping("/del/{id}")
    public AjaxResult remove(@PathVariable Long id) {
        // 先删除报价记录
        supplierGoodsPriceMapper.delete(new LambdaQueryWrapper<ErpSupplierGoodsPrice>()
                .eq(ErpSupplierGoodsPrice::getSupplierProductItemId, id));
        // 再删除SKU
        return toAjax(supplierProductItemService.removeById(id));
    }

    /**
     * 绑定商品库SKU（关联ERP商品库SKU）
     */
    @PutMapping("/bind")
    public AjaxResult bind(@RequestBody ErpSupplierProductItem bo) {
        ErpSupplierProductItem update = new ErpSupplierProductItem();
        update.setId(bo.getId());
        update.setErpGoodsSkuId(bo.getErpGoodsSkuId());
        update.setErpGoodsId(bo.getErpGoodsId());
        return toAjax(supplierProductItemService.updateById(update));
    }
}
