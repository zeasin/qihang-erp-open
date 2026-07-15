package cn.qihangerp.service;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.model.bo.SupplierShipConfirmRequest;
import cn.qihangerp.model.entity.OOrderStocking;
import cn.qihangerp.model.entity.OOrderStockingItem;
import cn.qihangerp.model.bo.StockingOrderBo;
import cn.qihangerp.model.bo.WarehouseManualShipOrderBo;
import cn.qihangerp.model.vo.PushOrderToShipperResult;
import cn.qihangerp.request.CloudWarehouseShipOrderQueryRequest;
import cn.qihangerp.request.ShipRecordQueryRequest;
import cn.qihangerp.request.SupplierShipOrderSearchRequest;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
* @author qilip
* @description 针对表【o_supplier_ship_order(供应商发货订单)】的数据库操作Service
* @createDate 2025-02-18 11:56:14
*/
public interface OOrderStockingService extends IService<OOrderStocking> {
    /**
     * 分配给供应商发货（order维度）
     * @param orderId
     * @return
     */
    ResultVo<Long> distributeOrderToSupplierShip(Long orderId,Long supplierId);
    /**
     * 推送订单到仓库发货（系统云仓）
     * @param
     * @return
     */
    ResultVo<PushOrderToShipperResult> pushOrderItemToCloudWarehouse(Long merchantId);

    ResultVo<PushOrderToShipperResult> pushOrderItemToSupplier(Long merchantId);


    PageResult<OOrderStocking> queryPageList(SupplierShipOrderSearchRequest bo, PageQuery pageQuery);

    /**
     * 供应商发货的订单list
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OOrderStocking> querySupplierShipPageList(SupplierShipOrderSearchRequest bo, PageQuery pageQuery);

    /**
     * 云仓发货订单list
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OOrderStocking> queryCloudWarehouseShipPageList(CloudWarehouseShipOrderQueryRequest bo, PageQuery pageQuery);
    List<OOrderStocking> queryCloudWarehouseShipList(CloudWarehouseShipOrderQueryRequest bo);


    /**
     * 仓库备货列表
     * @param request
     * @param pageQuery
     * @return
     */
    PageResult<OOrderStocking> queryStockUpPageList(StockingOrderBo request, PageQuery pageQuery);
    OOrderStocking queryDetailById(Long id);
    List<OOrderStockingItem> getItemsByOrderId(Long shipOrderId);

    /**
     * 查询发货单明细（订单号）
     * @param orderNum
     * @return
     */
    List<OOrderStockingItem> getItemsByOrderNum(String orderNum);

    List<OOrderStocking> getByOrderNum(String orderNum);

    /**
     * 系统云仓手动填写发货物流信息
     * @param bo
     * @param operator
     * @return
     */
    ResultVo<Integer> cloudWarehouseShipOrderManualLogistics(WarehouseManualShipOrderBo bo, String operator,Long warehouseId);

    /**
     * 仓库系统 生成出库单 （按发货订单）
     * @param stockingId
     * @return
     */
//    ResultVo warehouseGenerateStockOutByShipOrder(Long stockingId);

    /**
     * 更新京东云仓发货订单信息(自动任务)
     * @param deliveryOrderId
     * @param logisticsCode
     * @param logisticsName
     * @param waybillCode
     * @return
     */
    ResultVo<Long> updateJdlDeliveryOrderInfo(String deliveryOrderId,String logisticsCode,String logisticsName,String waybillCode);

    /**
     * 供应商发货确认
     * @param bo
     * @param operator
     * @return
     */
    ResultVo<Integer> supplierShipOrderManualLogistics(SupplierShipConfirmRequest bo, String operator);

    /**
     * 统一发货记录查询（根据type区分本地仓/供应商/云仓）
     * @param request 查询参数
     * @param pageQuery 分页参数
     * @return
     */
    PageResult<OOrderStocking> queryShipRecordPageList(ShipRecordQueryRequest request, PageQuery pageQuery);
}
