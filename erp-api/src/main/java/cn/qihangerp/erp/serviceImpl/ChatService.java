package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.erp.serviceImpl.ai.AiOrchestrationService;
import cn.qihangerp.erp.serviceImpl.ai.GoodsTools;
import cn.qihangerp.erp.serviceImpl.ai.InventoryTools;
import cn.qihangerp.erp.serviceImpl.ai.MemberTools;
import cn.qihangerp.erp.serviceImpl.ai.OrderTools;
import cn.qihangerp.erp.serviceImpl.ai.LogisticsTools;
import cn.qihangerp.erp.serviceImpl.ai.PurchaseTools;
import cn.qihangerp.erp.serviceImpl.ai.RefundTools;
import cn.qihangerp.erp.serviceImpl.ai.ShopTools;
import cn.qihangerp.erp.serviceImpl.ai.StockFlowTools;
import cn.qihangerp.erp.serviceImpl.ai.SupplierTools;
import cn.qihangerp.erp.serviceImpl.ai.WarehouseTools;
import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.model.entity.AiConversationHistory;
import cn.qihangerp.service.AiConversationHistoryService;
import com.alibaba.fastjson2.JSONObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class ChatService {

    private final AiConversationHistoryService historyService;
    private final AiOrchestrationService orchestrationService;
    private final GoodsTools goodsTools;
    private final OrderTools orderTools;
    private final RefundTools refundTools;
    private final InventoryTools inventoryTools;
    private final ShopTools shopTools;
    private final PurchaseTools purchaseTools;
    private final MemberTools memberTools;
    private final SupplierTools supplierTools;
    private final LogisticsTools logisticsTools;
    private final WarehouseTools warehouseTools;
    private final StockFlowTools stockFlowTools;

    private static final String SYSTEM_PROMPT = """
            你是启航电商ERP系统的AI助手，帮助用户处理电商运营、订单管理、商品管理、库存管理、采购管理、仓库管理、售后管理等方面的问题。请用专业、简洁的中文回答。
            
            你可以多次调用工具来逐步获取数据，每次根据返回的结果决定下一步查什么。
            所有工具的说明和参数已内置，由你自行决定每次调哪些工具、需要什么筛选条件。
            由你自行对数据进行分组、排序、统计、对比，得出结论。
            """;

    public void streamResponse(AiConfig config, SseEmitter emitter, String sessionId, Long userId) {
        try {
            List<AiConversationHistory> history = historyService.getConversation(sessionId);

            List<Message> messages = new ArrayList<>();
            messages.add(new SystemMessage(SYSTEM_PROMPT));
            for (AiConversationHistory msg : history) {
                if ("user".equals(msg.getRole())) {
                    messages.add(new UserMessage(msg.getContent()));
                } else {
                    messages.add(new AssistantMessage(msg.getContent()));
                }
            }

            ChatClient chatClient = orchestrationService.buildChatClient(config, goodsTools, orderTools, refundTools, inventoryTools, shopTools, purchaseTools, memberTools, supplierTools, logisticsTools, warehouseTools, stockFlowTools);

            StringBuilder fullResponse = new StringBuilder();

            chatClient.prompt()
                    .messages(messages.toArray(new Message[0]))
                    .stream()
                    .content()
                    .subscribe(
                            chunk -> {
                                fullResponse.append(chunk);
                                sendJsonEvent(emitter, "message", chunk);
                            },
                            error -> {
                                log.error("AI stream error", error);
                                sendJsonEvent(emitter, "error", "AI服务出错: " + error.getMessage());
                                safeComplete(emitter);
                            },
                            () -> {
                                String reply = fullResponse.toString();
                                if (!reply.isEmpty()) {
                                    historyService.saveMessage(sessionId, userId, "assistant", reply);
                                }
                                sendJsonEvent(emitter, "done", "");
                                safeComplete(emitter);
                            }
                    );

        } catch (Exception e) {
            log.error("AI对话处理异常", e);
            sendJsonEvent(emitter, "error", "系统错误: " + e.getMessage());
            safeComplete(emitter);
        }
    }

    private void sendJsonEvent(SseEmitter emitter, String type, String content) {
        try {
            JSONObject event = new JSONObject();
            event.put("type", type);
            if (content != null) {
                event.put("content", content);
            }
            emitter.send(SseEmitter.event().data(event.toJSONString()));
        } catch (IOException e) {
            log.warn("发送SSE事件失败: {}", e.getMessage());
        }
    }

    private void safeComplete(SseEmitter emitter) {
        try {
            emitter.complete();
        } catch (Exception ignored) {
        }
    }
}
