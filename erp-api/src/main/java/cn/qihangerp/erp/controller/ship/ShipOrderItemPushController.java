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
 * 云仓/供应商发货Controller - 推送订单Item到云仓/供应商（保存到备货表）
 */
@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/ship/order")
public class ShipOrderItemPushController extends BaseController {

    private final OOrderStockingService stockingService;

    /**
     * 推送订单Item到云仓（按订单Item维度）
     */
    @PostMapping("/push_order_item_to_cloud_warehouse")
    public AjaxResult pushOrderItemToCloudWarehouse(@RequestBody Map<String, List<Long>> request) {
        List<Long> ids = request.get("ids");
        var result = stockingService.pushOrderItemToCloudWarehouseByIds(ids);
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getMsg());
    }

    /**
     * 推送订单商品到供应商发货（按商品维度）
     */
    @PostMapping("/push_order_item_to_supplier")
    public AjaxResult pushOrderItemToSupplier(@RequestBody Map<String, Object> request) {
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
            return AjaxResult.error("请选择要推送的商品");
        }
        if (supplierId == null || supplierId <= 0) {
            return AjaxResult.error("缺少参数：供应商ID");
        }

        var result = stockingService.batchDistributeOrderItemToSupplierShip(ids, supplierId);
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getMsg());
    }
}