package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.erp.notify.NotifierService;
import cn.qihangerp.erp.serviceImpl.ai.AiOrchestrationService;
import cn.qihangerp.erp.serviceImpl.ai.InventoryTools;
import cn.qihangerp.erp.serviceImpl.ai.RefundTools;
import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.model.entity.SysMessage;
import cn.qihangerp.model.vo.SalesDailyVo;
import cn.qihangerp.service.ISysMessageService;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.ShopRefundService;
import cn.qihangerp.sse.SseService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
@RequiredArgsConstructor
public class MessageScheduler {

    private final OOrderService orderService;
    private final ShopRefundService refundService;
    private final ISysMessageService messageService;
    private final AiOrchestrationService orchestrationService;
    private final RefundTools refundTools;
    private final InventoryTools inventoryTools;
    private final NotifierService notifierService;
    private final SseService sseService;

    private static final List<String> NEED_NOTIFY_TYPES = List.of("stock_low", "order_timeout", "ai_analysis");

    @Scheduled(fixedRate = 1800000)
    public void run() {
        log.info("======自动分析====");
//        checkSalesZero();
//        checkShipPending();
//        checkRefundExcess();
//        checkStockLow();
//        checkOrderTimeout();
//        checkAiAnalysis();
    }

    @Scheduled(fixedRate = 600000)
    public void retryFailedNotify() {
        List<SysMessage> failed = messageService.getFailedNotify();
        for (SysMessage msg : failed) {
            boolean allOk = notifierService.notifyAll(msg.getTitle(), msg.getContent());
            msg.setNotifyStatus(allOk ? 1 : 2);
            msg.setNotifyTime(LocalDateTime.now());
            messageService.save(msg);
        }
        if (!failed.isEmpty()) log.info("重试推送 {} 条消息", failed.size());
    }

    private void checkSalesZero() {
        SalesDailyVo today = orderService.getTodaySalesDaily(0L);
        if (today != null && today.getAmount() != null && today.getAmount() > 0) return;
        save("sales_zero", "high", "今日销售额为零", "今日暂无销售额，请检查运营情况", "/sale/shop_order_list", "system");
    }

    private void checkShipPending() {
        Integer count = orderService.getWaitShipOrderAllCount(0L);
        if (count == null || count < 50) return;
        save("ship_pending", "medium", "发货积压提醒", "待发货订单" + count + "单，请尽快安排发货", "/sale/shop_order_list", "system");
    }

    private void checkRefundExcess() {
        LambdaQueryWrapper<ShopRefund> w = new LambdaQueryWrapper<>();
        w.ge(ShopRefund::getCreateOn, LocalDateTime.now().minusDays(30));
        long count = refundService.count(w);
        if (count < 20) return;
        save("refund_excess", "medium", "退款过多提醒", "近30天退款" + count + "单，请关注退款原因", "/sale/shop_refund", "system");
    }

    private void checkStockLow() {
        // TODO: query OGoodsSku with lowQty > availableQty
        // save("stock_low", "high", "库存不足: 商品名", "SKU xxx 库存仅剩 n 件")
    }

    private void checkOrderTimeout() {
        // TODO: query OOrder with status 0/1 and createTime > 4h
        // save("order_timeout", "medium", "发货超时提醒", "n 个订单超过 4 小时未发货")
    }

    private void checkAiAnalysis() {
        try {
            ChatClient cc = orchestrationService.buildDefaultChatClient(refundTools, inventoryTools);
            String result = CompletableFuture.supplyAsync(() ->
                    cc.prompt().user("""
                            你是电商运营监控助手，请查询数据检查是否存在异常：

                            如果有异常，按以下格式返回JSON数组，没有则返回[]：
                            [{"type":"ai_analysis","level":"high","title":"异常标题","content":"异常描述"}]
                            只返回JSON数组，不要其他文字。
                            """).call().content()
            ).get(60, TimeUnit.SECONDS);

            if (result == null || result.isBlank() || result.trim().equals("[]")) return;

            String json = result.trim().replaceAll("```json\\s*", "").replaceAll("```\\s*", "");
            if (!json.startsWith("[")) { int i = json.indexOf("["); if (i >= 0) json = json.substring(i); else return; }

            var items = com.alibaba.fastjson2.JSONArray.parseArray(json, com.alibaba.fastjson2.JSONObject.class);
            for (var item : items) {
                save("ai_analysis", item.getString("level"), item.getString("title"), item.getString("content"), "", "ai");
            }
        } catch (Exception e) {
            log.warn("AI消息检查失败", e);
        }
    }

    private void save(String type, String level, String title, String content, String link, String source) {
        boolean needNotify = "high".equals(level) || NEED_NOTIFY_TYPES.contains(type);

        SysMessage m = new SysMessage();
        m.setType(type);
        m.setLevel(level);
        m.setTitle(title);
        m.setContent(content);
        m.setLink(link);
        m.setSource(source);
        m.setIsRead(0);
        m.setNeedNotify(needNotify ? 1 : 0);
        m.setNotifyStatus(0);
        m.setCreatedTime(LocalDateTime.now());
        messageService.save(m);

        if (needNotify) {
            boolean allOk = notifierService.notifyAll(title, content);
            m.setNotifyStatus(allOk ? 1 : 2);
            m.setNotifyTime(LocalDateTime.now());
            messageService.save(m);
        }

        sseService.broadcastMessage("message", Map.of(
                "type", type, "level", level,
                "title", title, "content", content, "id", m.getId()));

        log.info("消息: [{}] {} (needNotify={})", level, title, needNotify);
    }
}
