package cn.qihangerp.service.impl;

import cn.qihangerp.model.entity.SysConfig;
import cn.qihangerp.mapper.SysConfigMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import cn.qihangerp.service.SysConfigService;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
* @author qilip
* @description 针对表【sys_config(参数配置表)】的数据库操作Service实现
* @createDate 2024-10-23 21:02:48
*/
@AllArgsConstructor
@Service
public class SysConfigServiceImpl extends ServiceImpl<SysConfigMapper, SysConfig>
    implements SysConfigService{
    private final SysConfigMapper configMapper;

    @Override
    public boolean selectCaptchaEnabled() {
        List<SysConfig> sysConfigs = configMapper.selectList(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, "sys.account.captchaEnabled"));
        if(sysConfigs==null || sysConfigs.isEmpty())
         return false;
        else if(sysConfigs.get(0).getConfigValue().equals("true")){
            return true;
        }else return false;
    }

    @Override
    public boolean selectManualAuditEnabled() {
        List<SysConfig> sysConfigs = configMapper.selectList(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, "order.manual_audit.enabled"));
        if (sysConfigs == null || sysConfigs.isEmpty()) {
            return true;
        }
        return "true".equalsIgnoreCase(sysConfigs.get(0).getConfigValue());
    }

    @Override
    public String selectConfigByKey(String configKey) {
        if (configKey == null || configKey.isEmpty()) {
            return null;
        }
        List<SysConfig> sysConfigs = configMapper.selectList(
                new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, configKey));
        return (sysConfigs == null || sysConfigs.isEmpty()) ? null : sysConfigs.get(0).getConfigValue();
    }
}




