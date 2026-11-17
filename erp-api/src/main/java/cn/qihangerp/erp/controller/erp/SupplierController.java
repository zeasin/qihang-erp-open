package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.enums.EnumUserType;
import cn.qihangerp.model.entity.ErpSupplier;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.security.common.SecurityUtils;
import cn.qihangerp.service.ErpSupplierService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.time.LocalDateTime;

@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/supplier")
public class SupplierController extends BaseController {
    private final ErpSupplierService supplierService;

    /**
     * Returns the merchant ids the current user may access.
     * null means no restriction (platform administrator).
     */
    private List<Long> resolveMerchantIds() {
        Integer identity = SecurityUtils.getUserIdentity();
        if (identity == null) return List.of(-1L);
        if (identity == EnumUserType.SUPPER.getIndex()) return null;
        if (identity == EnumUserType.MERCHANT.getIndex()) return List.of(SecurityUtils.getDeptId());
        return List.of(-1L);
    }

    /**
     * 所有供应商list
     * @param bo
     * @param pageQuery
     * @return
     */
    @GetMapping("/list_all")
    public TableDataInfo list_all(ErpSupplier bo, PageQuery pageQuery) {
        List<Long> merchantIds = resolveMerchantIds();
        if (merchantIds != null) {
            bo.setMerchantId(merchantIds.get(0));
        }
        var pageList = supplierService.list(new LambdaQueryWrapper<ErpSupplier>()
                .eq(ErpSupplier::getIsDelete,0)
                .eq(merchantIds != null, ErpSupplier::getMerchantId, merchantIds != null ? merchantIds.get(0) : null)
                .eq(bo.getIsShipper()!=null,ErpSupplier::getIsShipper,bo.getIsShipper())
        );
        return getDataTable(pageList);
    }
    @GetMapping("/list")
    public TableDataInfo list(ErpSupplier bo, PageQuery pageQuery)
    {
        List<Long> merchantIds = resolveMerchantIds();
        if (merchantIds != null) {
            bo.setMerchantId(merchantIds.get(0));
        }
        var pageList = supplierService.queryPageList(bo,pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 获取【请填写功能名称】详细信息
     */
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        ErpSupplier supplier = supplierService.getById(id);
        List<Long> merchantIds = resolveMerchantIds();
        if (supplier != null && merchantIds != null
                && (supplier.getMerchantId() == null || !merchantIds.contains(supplier.getMerchantId()))) {
            return AjaxResult.error("无权访问该数据");
        }
        return success(supplier);
    }

    /**
     * 新增【请填写功能名称】
     */
    @PostMapping
    public AjaxResult add(@RequestBody ErpSupplier scmSupplier)
    {
//        scmSupplier.setCreatetime(LocalDateTime.now());
//        scmSupplier.setIsdelete(0);
        return toAjax(supplierService.save(scmSupplier));
    }

    /**
     * 修改【请填写功能名称】
     */
    @PutMapping
    public AjaxResult edit(@RequestBody ErpSupplier scmSupplier)
    {
        return toAjax(supplierService.updateById(scmSupplier));
    }

    /**
     * 删除【请填写功能名称】
     */
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(supplierService.removeByIds(Arrays.stream(ids).toList()));
    }
}
