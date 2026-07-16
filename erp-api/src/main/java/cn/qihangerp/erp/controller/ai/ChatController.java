package cn.qihangerp.erp.controller.ai;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.serviceImpl.ChatService;
import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.model.entity.AiConversationHistory;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.AiConfigService;
import cn.qihangerp.service.AiConversationHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.UUID;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/ai")
public class ChatController extends BaseController {

    private final ChatService chatService;
    private final AiConfigService aiConfigService;
    private final AiConversationHistoryService historyService;

    @PostMapping(value = "/chat/send", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter sendMessage(@RequestBody ChatSendRequest req) {
        String sessionId = req.getSessionId() != null && !req.getSessionId().isEmpty()
                ? req.getSessionId() : UUID.randomUUID().toString();
        Long userId = getUserId();

        historyService.saveMessage(sessionId, userId, "user", req.getMessage());

        AiConfig config = aiConfigService.getDefaultConfig();
        if (config == null) {
            return errorEmitter("请先在 AI 智能 > 模型配置 中添加并启用默认模型");
        }

        SseEmitter emitter = new SseEmitter(180000L);
        chatService.streamResponse(config, emitter, sessionId, userId);
        return emitter;
    }

    @GetMapping("/chat/history")
    public AjaxResult getHistory(@RequestParam String sessionId) {
        List<AiConversationHistory> list = historyService.getConversation(sessionId);
        return AjaxResult.success(list);
    }

    @GetMapping("/chat/sessions")
    public AjaxResult getSessions() {
        List<String> sessions = historyService.getSessions(getUserId());
        return AjaxResult.success(sessions);
    }

    @DeleteMapping("/chat/session/{sessionId}")
    public AjaxResult deleteSession(@PathVariable String sessionId) {
        historyService.deleteSession(sessionId, getUserId());
        return AjaxResult.success();
    }

    private SseEmitter errorEmitter(String msg) {
        SseEmitter emitter = new SseEmitter();
        try {
            emitter.send(SseEmitter.event().data(
                    "{\"type\":\"error\",\"content\":\"" + msg + "\"}"));
            emitter.complete();
        } catch (Exception ignored) {}
        return emitter;
    }

    public static class ChatSendRequest {
        private String sessionId;
        private String message;

        public String getSessionId() { return sessionId; }
        public void setSessionId(String sessionId) { this.sessionId = sessionId; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
