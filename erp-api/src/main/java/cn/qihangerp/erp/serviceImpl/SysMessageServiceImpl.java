package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.mapper.SysMessageMapper;
import cn.qihangerp.model.entity.SysMessage;
import cn.qihangerp.service.ISysMessageService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SysMessageServiceImpl implements ISysMessageService {

    private final SysMessageMapper mapper;

    @Override
    public void save(SysMessage msg) {
        if (msg.getCreatedTime() == null) {
            msg.setCreatedTime(LocalDateTime.now());
        }
        if (msg.getId() != null) {
            mapper.updateById(msg);
        } else {
            mapper.insert(msg);
        }
    }

    @Override
    public List<SysMessage> getUnread() {
        LambdaQueryWrapper<SysMessage> w = new LambdaQueryWrapper<>();
        w.eq(SysMessage::getIsRead, 0);
        w.orderByDesc(SysMessage::getCreatedTime);
        return mapper.selectList(w);
    }

    @Override
    public long countUnread() {
        LambdaQueryWrapper<SysMessage> w = new LambdaQueryWrapper<>();
        w.eq(SysMessage::getIsRead, 0);
        return mapper.selectCount(w);
    }

    @Override
    public void markRead(Long id) {
        SysMessage m = mapper.selectById(id);
        if (m != null) {
            m.setIsRead(1);
            m.setReadTime(LocalDateTime.now());
            mapper.updateById(m);
        }
    }

    @Override
    public List<SysMessage> getFailedNotify() {
        LambdaQueryWrapper<SysMessage> w = new LambdaQueryWrapper<>();
        w.eq(SysMessage::getNeedNotify, 1);
        w.eq(SysMessage::getNotifyStatus, 2);
        w.lt(SysMessage::getNotifyTime, LocalDateTime.now().minusMinutes(10));
        w.orderByAsc(SysMessage::getNotifyTime);
        w.last("LIMIT 20");
        return mapper.selectList(w);
    }

    @Override
    public void markAllRead() {
        LambdaQueryWrapper<SysMessage> w = new LambdaQueryWrapper<>();
        w.eq(SysMessage::getIsRead, 0);
        SysMessage update = new SysMessage();
        update.setIsRead(1);
        update.setReadTime(LocalDateTime.now());
        mapper.update(update, w);
    }
}
