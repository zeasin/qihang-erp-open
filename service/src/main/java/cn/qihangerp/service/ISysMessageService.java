package cn.qihangerp.service;

import cn.qihangerp.model.entity.SysMessage;

import java.util.List;

public interface ISysMessageService {
    void save(SysMessage msg);
    List<SysMessage> getUnread();
    long countUnread();
    void markRead(Long id);
    void markAllRead();
}
