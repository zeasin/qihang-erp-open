package cn.qihangerp.service;


import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.model.entity.OOrderItem;
import cn.qihangerp.model.query.OrderItemQuery;
import cn.qihangerp.model.vo.OrderItemListVo;
import cn.qihangerp.request.OrderSearchRequest;
import com.baomidou.mybatisplus.extension.service.IService;


import java.util.List;

/**
* @author TW
* @description 针对表【o_order_item(订单明细表)】的数据库操作Service
* @createDate 2024-03-11 14:24:49
*/
public interface OOrderItemService extends IService<OOrderItem> {
    PageResult<OrderItemListVo> selectPageVo(PageQuery pageQuery, OrderItemQuery bo);
    List<OrderItemListVo> selectExportListVo(OrderItemQuery bo);
    PageResult<OOrderItem> queryPageList(OOrderItem bo, PageQuery pageQuery);
    /**
     * 查询待发货的orderitem（不含未分配）
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OrderItemListVo> queryWaitDistOrderItemPageList(OrderSearchRequest bo, PageQuery pageQuery);
    ResultVo<Integer>  updateErpSkuId(Long orderItemId,String skuId);
    ResultVo<Long>  updateShipSupplierId(Long orderItemId,Long supplierId);

    /**
     * 修改发货人（批量）
     * @param orderItemId
     * @param shipType
     * @param shipperId
     * @return
     */
    ResultVo<Long>  updateShipperId(Long[] orderItemId,Integer shipType,Long shipperId);

    List<OOrderItem> getOrderItemListByOrderId(Long orderId);
    List<OOrderItem> getOrderItemListByOrderNum(String orderId);
//    List<SalesTopSkuVo> selectTopSku(String startDate, String endDate);
//    int orderItemSpecIdUpdate(OrderItemSpecIdUpdateBo bo);

    /**
     * 查询所有待推送的订单明细关联的orderId（已分配仓库发货、供应商发货)
     * @return
     */
    List<Long> selectOrderItemWaitPushSupplierOrderIdList(Long merchantId);

    }
