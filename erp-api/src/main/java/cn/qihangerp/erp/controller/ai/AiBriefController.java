package cn.qihangerp.erp.controller.ai;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.serviceImpl.AiBriefService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * AI工作台简报 - 管理者首页智能看板数据
 */
@Slf4j
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiBriefController {

    private final AiBriefService aiBriefService;

    @GetMapping("/brief")
    public AjaxResult getBrief() {
        AiBriefService.AiBriefResponse brief = aiBriefService.generateBrief();
        return AjaxResult.success(brief);
    }
}