package cn.qihangerp.erp.controller.ship;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.OOrderStockingService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 供应商发货Controller - 分配订单到供应商发货
 */
@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/ship/vendor")
public class ShipOrderVendorController extends BaseController {

    private final OOrderStockingService stockingService;

    /**
     * 推送订单到供应商发货（按订单维度）
     */
    @PostMapping("/pushOrderToSupplier")
    public AjaxResult pushOrderToSupplier(@RequestBody Map<String, Object> request) {
        @SuppressWarnings("unchecked")
        List<Long> ids = (List<Long>) request.get("ids");
        Object supplierIdObj = request.get("supplierId");
        Long supplierId = null;
        if (supplierIdObj instanceof Number) {
            supplierId = ((Number) supplierIdObj).longValue();
        } else if (supplierIdObj instanceof String) {
            supplierId = Long.parseLong((String) supplierIdObj);
        }

        if (ids == null || ids.isEmpty()) {
            return AjaxResult.error("请选择要推送的订单");
        }
        if (supplierId == null || supplierId <= 0) {
            return AjaxResult.error("缺少参数：供应商ID");
        }

        var result = stockingService.batchDistributeOrderToSupplierShip(ids, supplierId);
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getMsg());
    }
}