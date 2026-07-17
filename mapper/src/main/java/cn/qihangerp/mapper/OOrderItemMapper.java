package cn.qihangerp.mapper;

import cn.qihangerp.model.entity.OOrderItem;
import cn.qihangerp.model.query.OrderItemQuery;
import cn.qihangerp.model.vo.OrderItemListVo;
import cn.qihangerp.model.vo.SalesTopSkuVo;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;


import java.util.List;

/**
* @author TW
* @description 针对表【o_order_item(订单明细表)】的数据库操作Mapper
* @createDate 2024-03-11 14:24:49
* @Entity cn.qihangerp.model.entity.OOrderItem
*/
public interface OOrderItemMapper extends BaseMapper<OOrderItem> {
    Page<OrderItemListVo> selectPageVo(@Param("page") Page<OrderItemListVo> page, @Param("qw") OrderItemQuery qw);
    List<OrderItemListVo> selectListVo( @Param("qw") OrderItemQuery qw);
    List<OrderItemListVo> selectOrderItemListByOrderId(@Param("orderId") Long orderId);
    List<SalesTopSkuVo> selectTopSku(@Param("startDate") String startDate, @Param("endDate") String endDate);

    /**
     * 查询所有待推送的订单明细关联的orderId（已分配供应商发货)
     * @return
     */
    List<Long> selectOrderItemWaitPushSupplierOrderIdList(@Param("merchantId") Long merchantId);
}




