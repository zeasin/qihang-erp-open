package cn.qihangerp.erp.controller;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.service.ISysMessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/sys/message")
@RequiredArgsConstructor
public class SysMessageController {

    private final ISysMessageService messageService;

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
}
