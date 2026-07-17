package cn.qihangerp.service;

import cn.qihangerp.model.entity.OOrder;
import cn.qihangerp.model.entity.OOrderItem;
import cn.qihangerp.model.bo.ErpOrderShipBo;
import cn.qihangerp.model.bo.PushToCloudWarehouseOrderBo;
import cn.qihangerp.model.vo.SalesDailyVo;
import cn.qihangerp.model.vo.WaitShipReportVo;
import cn.qihangerp.request.OrderSearchRequest;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;



import java.util.List;

/**
* @author qilip
* @description 针对表【o_order(订单表)】的数据库操作Service
* @createDate 2024-03-09 13:15:57
*/
public interface OOrderService extends IService<OOrder> {

    ResultVo<Long> erpOrderMessage(String orderNum);
    ResultVo<Long> shopOrderMessage(Long shopOrderId);
    List<OOrder> getList(OOrder order);
    PageResult<OOrder> queryPageList(OrderSearchRequest bo, PageQuery pageQuery);
    PageResult<OOrder> queryWaitDistOrderPageList(OrderSearchRequest bo, PageQuery pageQuery);

    /**
     * 更新订单状态
     * @param orderNo
     * @param orderStatus
     * @param refundStatus
     * @return
     */
    ResultVo<Long> updateOrderStatus(String orderNo, Integer orderStatus, Integer refundStatus);
    /**
     * 已经发货的list(自己发货)
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OOrder> querySelfShippedPageList(OrderSearchRequest bo, PageQuery pageQuery);

    OOrder queryDetailAndCouponById(Long id);
    OOrder queryDetailById(Long id);

    OOrder queryDetailByOrderNum(String orderNum);
    OOrder queryByOrderNum(String orderNum);

    List<OOrder> searchOrderConsignee(String consignee);
    List<OOrderItem> searchOrderItemByReceiverMobile(String receiverMobile);
    List<OOrderItem> queryItemList(String orderId);

    /**
     * 待发货统计
     * @return
     */
    List<WaitShipReportVo> waitOrderReport(Long merchantId);
    List<SalesDailyVo> salesDaily();
    SalesDailyVo getTodaySalesDaily(Long merchantId);
    Integer getWaitShipOrderAllCount(Long merchantId);
//    ResultVo<Integer> saveWaybillCode(String orderNum,Long shopId,Integer shopType, String WaybillCode);
    /**
     * 手动发货(本地发货)
     * @param shipBo
     * @return 返回备货单id
     */
    ResultVo<Long> localManualShipmentOrder(ErpOrderShipBo shipBo, String createBy);

    /**
     * 推送订单到云仓（京东云仓、系统云仓）
     * @param
     * @param
     * @return
     */
    ResultVo<Long> pushOrderToCloudWarehouse(PushToCloudWarehouseOrderBo bo);

    /**
     * 取消店铺订单
     * @param shopOrderId
     * @return
     */
    ResultVo cancelShopOrder(Long shopOrderId);

    /**
     * 取消抖店订单
     * @param douOrderId
     * @return
     */
    ResultVo cancelDouOrderMessage(String douOrderId);
}
