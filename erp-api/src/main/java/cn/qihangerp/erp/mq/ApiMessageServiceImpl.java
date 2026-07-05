package cn.qihangerp.erp.mq;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.mq.MqMessage;
import cn.qihangerp.common.mq.MqType;
import cn.qihangerp.model.entity.ShopOrder;
import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.ORefundService;
import cn.qihangerp.service.ShopOrderService;
import cn.qihangerp.service.ShopRefundService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * API 消息处理实现（Redis Pub/Sub 驱动）。<br>
 * 设计：MQ 消息的 keyId 为平台订单号/售后单号，本类据此查找已落库的 oms_shop_order / oms_shop_refund，
 * 再调用统一同步方法把数据同步到 o_order / o_refund。<br>
 * 说明：平台新订单的"拉取"由 ShopPullApiService.pullOrder 负责；本类只负责"同步触发"，
 * 适用于：① pull_list 拉取后回调通知 ② 平台主动推送通知 ③ 补偿已有数据的同步。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiMessageServiceImpl implements ApiMessageService {

    private final ShopOrderService shopOrderService;
    private final ShopRefundService shopRefundService;
    private final OOrderService oOrderService;
    private final ORefundService oRefundService;

    @Override
    public ResultVo<Integer> messageHandle(MqMessage mqMessage) {
        if (mqMessage == null) {
            return ResultVo.error("消息为空");
        }
        try {
            if (mqMessage.getMqType() == MqType.ORDER_MESSAGE) {
                return handleOrderMessage(mqMessage);
            } else if (mqMessage.getMqType() == MqType.REFUND_MESSAGE) {
                return handleRefundMessage(mqMessage);
            } else {
                log.info("未处理的消息类型：{}", mqMessage.getMqType());
                return ResultVo.success(0);
            }
        } catch (Exception e) {
            log.error("处理API消息异常：{}", mqMessage, e);
            return ResultVo.error("处理消息异常：" + e.getMessage());
        }
    }

    /**
     * 订单消息：keyId = 平台订单号 → 查 ShopOrder → 同步到 o_order
     */
    private ResultVo<Integer> handleOrderMessage(MqMessage msg) {
        String orderNo = msg.getKeyId();
        if (orderNo == null || orderNo.isEmpty()) {
            return ResultVo.error("订单消息缺少keyId(订单号)");
        }
        ShopOrder shopOrder = shopOrderService.queryDetailByOrderNo(orderNo);
        if (shopOrder == null) {
            log.warn("订单消息：未找到 ShopOrder({}), 可能尚未拉取，请先调用 pull_list", orderNo);
            return ResultVo.error(404, "店铺订单尚未拉取，无法同步");
        }
        ResultVo<Long> r = oOrderService.shopOrderMessage(shopOrder.getId());
        log.info("订单消息处理完成：orderNo={}, shopOrderId={}, 同步结果={}", orderNo, shopOrder.getId(),
                r.getCode());
        return ResultVo.success(r.getCode() == 0 ? 1 : 0);
    }

    /**
     * 售后消息：keyId = 平台售后单号 → 查 ShopRefund → 同步到 o_refund
     */
    private ResultVo<Integer> handleRefundMessage(MqMessage msg) {
        String afterId = msg.getKeyId();
        if (afterId == null || afterId.isEmpty()) {
            return ResultVo.error("售后消息缺少keyId(售后单号)");
        }
        List<ShopRefund> refunds = shopRefundService.list(new LambdaQueryWrapper<ShopRefund>()
                .eq(ShopRefund::getAfterId, afterId));
        if (refunds == null || refunds.isEmpty()) {
            log.warn("售后消息：未找到 ShopRefund(afterId={}), 可能尚未拉取，请先调用 pull_list", afterId);
            return ResultVo.error(404, "店铺售后尚未拉取，无法同步");
        }
        int success = 0;
        for (ShopRefund refund : refunds) {
            try {
                ResultVo<Long> r = oRefundService.shopRefundMessage(refund.getId());
                if (r.getCode() == 0) success++;
                log.info("售后消息处理：afterId={}, shopRefundId={}, 同步结果={}", afterId, refund.getId(), r.getCode());
            } catch (Exception e) {
                log.error("售后消息同步异常：shopRefundId={}", refund.getId(), e);
            }
        }
        return ResultVo.success(success);
    }
}
