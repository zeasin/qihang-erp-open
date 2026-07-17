package cn.qihangerp.erp.controller;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.notify.NotifierService;
import cn.qihangerp.model.entity.SysMessage;
import cn.qihangerp.service.ISysMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/sys/message")
@RequiredArgsConstructor
public class SysMessageController {

    private final ISysMessageService messageService;
    private final NotifierService notifierService;

    @GetMapping("/unread")
    public AjaxResult getUnread() {
        return AjaxResult.success(messageService.getUnread());
    }

    @GetMapping("/count")
    public AjaxResult countUnread() {
        return AjaxResult.success(messageService.countUnread());
    }

    @PostMapping("/read/{id}")
    public AjaxResult markRead(@PathVariable Long id) {
        messageService.markRead(id);
        return AjaxResult.success();
    }

    @PostMapping("/read-all")
    public AjaxResult markAllRead() {
        messageService.markAllRead();
        return AjaxResult.success();
    }

    @PostMapping("/retry-notify")
    public AjaxResult retryNotify() {
        List<SysMessage> failed = messageService.getFailedNotify();
        int success = 0;
        for (SysMessage msg : failed) {
            boolean allOk = notifierService.notifyAll(msg.getTitle(), msg.getContent());
            msg.setNotifyStatus(allOk ? 1 : 2);
            msg.setNotifyTime(LocalDateTime.now());
            messageService.save(msg);
            if (allOk) success++;
        }
        return AjaxResult.success("重试完成，成功 " + success + "/" + failed.size() + " 条");
    }
}
