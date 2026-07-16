package cn.qihangerp.erp.controller.ai;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.service.AiConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/ai/config")
public class AiConfigController {

    private final AiConfigService aiConfigService;

    @GetMapping("/list")
    public AjaxResult list() {
        List<AiConfig> list = aiConfigService.list();
        return AjaxResult.success(list);
    }

    @GetMapping("/{id}")
    public AjaxResult getById(@PathVariable Long id) {
        return AjaxResult.success(aiConfigService.getById(id));
    }

    @PostMapping
    public AjaxResult add(@RequestBody AiConfig config) {
        config.setCreateTime(LocalDateTime.now());
        aiConfigService.save(config);
        return AjaxResult.success();
    }

    @PutMapping
    public AjaxResult edit(@RequestBody AiConfig config) {
        config.setUpdateTime(LocalDateTime.now());
        aiConfigService.updateById(config);
        return AjaxResult.success();
    }

    @DeleteMapping("/{id}")
    public AjaxResult remove(@PathVariable Long id) {
        aiConfigService.removeById(id);
        return AjaxResult.success();
    }

    @PutMapping("/{id}/default")
    public AjaxResult setDefault(@PathVariable Long id) {
        aiConfigService.setDefault(id);
        return AjaxResult.success();
    }
}
