package cn.qihangerp.erp.mq;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class MqConsumer {

    public void handleOrderMessage(String message) {
        // TODO: 订单消息消费，用于外部通知推送等场景
    }

    public void handleRefundMessage(String message) {
        // TODO: 售后消息消费，用于外部通知推送等场景
    }

    public void handleShipMessage(String message) {
        // TODO: 发货消息消费，用于外部通知推送等场景
    }
}
