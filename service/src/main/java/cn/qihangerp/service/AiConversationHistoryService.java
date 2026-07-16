package cn.qihangerp.service;

import cn.qihangerp.model.entity.AiConversationHistory;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface AiConversationHistoryService extends IService<AiConversationHistory> {
    List<AiConversationHistory> getConversation(String sessionId);
    void saveMessage(String sessionId, Long userId, String role, String content);
    List<String> getSessions(Long userId);
    void deleteSession(String sessionId, Long userId);
}
