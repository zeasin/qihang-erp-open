package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.mapper.AiConversationHistoryMapper;
import cn.qihangerp.model.entity.AiConversationHistory;
import cn.qihangerp.service.AiConversationHistoryService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AiConversationHistoryServiceImpl
        extends ServiceImpl<AiConversationHistoryMapper, AiConversationHistory>
        implements AiConversationHistoryService {

    @Override
    public List<AiConversationHistory> getConversation(String sessionId) {
        return lambdaQuery()
                .eq(AiConversationHistory::getSessionId, sessionId)
                .orderByAsc(AiConversationHistory::getTimestamp)
                .list();
    }

    @Override
    public void saveMessage(String sessionId, Long userId, String role, String content) {
        AiConversationHistory msg = new AiConversationHistory();
        msg.setSessionId(sessionId);
        msg.setUserId(userId);
        msg.setRole(role);
        msg.setContent(content);
        msg.setTimestamp(System.currentTimeMillis());
        msg.setCreateTime(LocalDateTime.now());
        msg.setUpdateTime(LocalDateTime.now());
        save(msg);
    }

    @Override
    public List<String> getSessions(Long userId) {
        return lambdaQuery()
                .eq(AiConversationHistory::getUserId, userId)
                .orderByDesc(AiConversationHistory::getTimestamp)
                .list()
                .stream()
                .map(AiConversationHistory::getSessionId)
                .distinct()
                .collect(Collectors.toList());
    }

    @Override
    public void deleteSession(String sessionId, Long userId) {
        lambdaUpdate()
                .eq(AiConversationHistory::getSessionId, sessionId)
                .eq(AiConversationHistory::getUserId, userId)
                .remove();
    }
}
