package cn.qihangerp.erp.controller.sys;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.model.entity.SysConfig;
import cn.qihangerp.service.SysConfigService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/api/sys-api/system/config")
public class SysConfigController {
    private final SysConfigService configService;

    @GetMapping(value = "/getConfigValue/{key}")
    public AjaxResult getConfigValue(@PathVariable String key)
    {
        List<SysConfig> list = configService.list(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, key));
        if(list!=null && !list.isEmpty())
        {
            return AjaxResult.success(list.get(0));
        }else{
            return AjaxResult.success();
        }
    }

    /**
     * 根据参数键名查询参数值
     * @param configKey 参数键名
     * @return
     */
    @GetMapping(value = "configKey/{configKey}")
    public AjaxResult getConfigByKey(@PathVariable String configKey)
    {
        List<SysConfig> list = configService.list(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, configKey));
        if(list!=null && !list.isEmpty())
        {
            return AjaxResult.success(list.get(0));
        }else{
            return AjaxResult.success();
        }
    }
}
