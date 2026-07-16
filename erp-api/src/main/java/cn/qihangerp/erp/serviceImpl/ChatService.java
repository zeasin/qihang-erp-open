package cn.qihangerp.erp.serviceImpl;

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
import org.springframework.ai.deepseek.DeepSeekChatModel;
import org.springframework.ai.deepseek.DeepSeekChatOptions;
import org.springframework.ai.deepseek.api.DeepSeekApi;
import org.springframework.ai.model.SimpleApiKey;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestClient;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class ChatService {

    private final AiConversationHistoryService historyService;

    private static final String SYSTEM_PROMPT = "你是启航电商ERP系统的AI助手，帮助用户处理电商运营、订单管理、商品管理、库存管理、采购管理、仓库管理、售后管理等方面的问题。请用专业、简洁的中文回答。";

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

            String baseUrl = config.getApiEndpoint().replaceAll("/v1/?$", "").replaceAll("/+$", "");

            DeepSeekApi api = DeepSeekApi.builder()
                    .baseUrl(baseUrl)
                    .apiKey(new SimpleApiKey(config.getApiKey()))
                    .completionsPath("/v1/chat/completions")
                    .build();

            DeepSeekChatModel chatModel = DeepSeekChatModel.builder()
                    .deepSeekApi(api)
                    .options(DeepSeekChatOptions.builder()
                            .model(config.getModelName())
                            .build())
                    .build();

            ChatClient chatClient = ChatClient.create(chatModel);

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
