package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.model.entity.AiConversationHistory;
import cn.qihangerp.service.AiConversationHistoryService;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@RequiredArgsConstructor
@Service
public class ChatService {

    private final AiConversationHistoryService historyService;

    private static final String SYSTEM_PROMPT = "你是启航电商ERP系统的AI助手，帮助用户处理电商运营、订单管理、商品管理、库存管理、采购管理、仓库管理、售后管理等方面的问题。请用专业、简洁的中文回答。";
    private static final MediaType JSON_MEDIA = MediaType.get("application/json; charset=utf-8");

    public void streamResponse(AiConfig config, SseEmitter emitter, String sessionId, Long userId) {
        CompletableFuture.runAsync(() -> {
            try {
                List<AiConversationHistory> history = historyService.getConversation(sessionId);

                JSONArray messages = new JSONArray();
                JSONObject systemMsg = new JSONObject();
                systemMsg.put("role", "system");
                systemMsg.put("content", SYSTEM_PROMPT);
                messages.add(systemMsg);

                for (AiConversationHistory msg : history) {
                    JSONObject m = new JSONObject();
                    m.put("role", msg.getRole());
                    m.put("content", msg.getContent());
                    messages.add(m);
                }

                JSONObject requestBody = new JSONObject();
                requestBody.put("model", config.getModelName());
                requestBody.put("messages", messages);
                requestBody.put("stream", true);

                String apiEndpoint = config.getApiEndpoint().replaceAll("/+$", "") + "/chat/completions";
                String requestJson = requestBody.toJSONString();

                OkHttpClient client = new OkHttpClient.Builder()
                        .readTimeout(0, java.util.concurrent.TimeUnit.SECONDS)
                        .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                        .build();

                Request okRequest = new Request.Builder()
                        .url(apiEndpoint)
                        .header("Authorization", "Bearer " + config.getApiKey())
                        .header("Content-Type", "application/json")
                        .post(RequestBody.create(requestJson, JSON_MEDIA))
                        .build();

                StringBuilder fullResponse = new StringBuilder();

                client.newCall(okRequest).enqueue(new okhttp3.Callback() {
                    @Override
                    public void onResponse(Call call, Response response) {
                        try (ResponseBody responseBody = response.body()) {
                            if (!response.isSuccessful()) {
                                String errorBody = responseBody != null ? responseBody.string() : "未知错误";
                                sendJsonEvent(emitter, "error", "AI服务返回错误: HTTP " + response.code() + " - " + errorBody);
                                emitter.complete();
                                return;
                            }

                            if (responseBody == null) {
                                sendJsonEvent(emitter, "error", "AI服务返回空响应");
                                emitter.complete();
                                return;
                            }

                            okio.BufferedSource source = responseBody.source();
                            String line;
                            while ((line = source.readUtf8Line()) != null) {
                                if (line.startsWith("data: ")) {
                                    String data = line.substring(6).trim();
                                    if ("[DONE]".equals(data)) {
                                        break;
                                    }
                                    try {
                                        JSONObject chunk = JSONObject.parseObject(data);
                                        JSONArray choices = chunk.getJSONArray("choices");
                                        if (choices != null && !choices.isEmpty()) {
                                            JSONObject choice = choices.getJSONObject(0);
                                            JSONObject delta = choice.getJSONObject("delta");
                                            if (delta != null && delta.getString("content") != null) {
                                                String content = delta.getString("content");
                                                fullResponse.append(content);
                                                sendJsonEvent(emitter, "message", content);
                                            }
                                            if ("stop".equals(choice.getString("finish_reason"))) {
                                                break;
                                            }
                                        }
                                    } catch (Exception e) {
                                        log.warn("解析AI响应chunk失败: {}", e.getMessage());
                                    }
                                }
                            }

                            String assistantReply = fullResponse.toString();
                            if (!assistantReply.isEmpty()) {
                                historyService.saveMessage(sessionId, userId, "assistant", assistantReply);
                            }

                            sendJsonEvent(emitter, "done", "");
                            emitter.complete();
                        } catch (Exception e) {
                            log.error("处理AI响应流失败", e);
                            sendJsonEvent(emitter, "error", "处理响应时出错: " + e.getMessage());
                            safeComplete(emitter);
                        }
                    }

                    @Override
                    public void onFailure(Call call, IOException e) {
                        log.error("AI服务调用失败", e);
                        sendJsonEvent(emitter, "error", "AI服务调用失败: " + e.getMessage());
                        safeComplete(emitter);
                    }
                });

            } catch (Exception e) {
                log.error("AI对话处理异常", e);
                sendJsonEvent(emitter, "error", "系统错误: " + e.getMessage());
                safeComplete(emitter);
            }
        });
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
