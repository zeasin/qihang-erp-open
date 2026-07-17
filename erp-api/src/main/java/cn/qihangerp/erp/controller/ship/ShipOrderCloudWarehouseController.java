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
 * 云仓发货Controller - 推送订单到云仓（保存到备货表）
 */
@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/ship/cloudWarehouse")
public class ShipOrderCloudWarehouseController extends BaseController {

    private final OOrderStockingService stockingService;

    /**
     * 推送订单到云仓（按订单维度）
     */
    @PostMapping("/pushToCloudWarehouse")
    public AjaxResult pushToCloudWarehouse(@RequestBody Map<String, List<Long>> request) {
        List<Long> ids = request.get("ids");
        var result = stockingService.pushOrderToCloudWarehouse(ids);
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getMsg());
    }
}