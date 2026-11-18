package cn.qihangerp.service;

import cn.qihangerp.model.entity.SysConfig;
import com.baomidou.mybatisplus.extension.service.IService;

/**
* @author qilip
* @description 针对表【sys_config(参数配置表)】的数据库操作Service
* @createDate 2024-10-23 21:02:48
*/
public interface SysConfigService extends IService<SysConfig> {
    boolean selectCaptchaEnabled();

    /**
     * 订单人工审单开关：true=拉单进入待审核池；false=拉单自动放行（配置缺失时默认 true）
     */
    boolean selectManualAuditEnabled();

    /**
     * 按配置键读取参数值。
     *
     * @param configKey 配置键（sys_config.config_key）
     * @return 配置值；配置不存在时返回 null
     */
    String selectConfigByKey(String configKey);

    /**
     * 按配置键读取参数值，配置缺失或为空时返回默认值。
     *
     * @param configKey   配置键（sys_config.config_key）
     * @param defaultValue 默认值
     * @return 配置值或默认值
     */
    default String selectConfigByKey(String configKey, String defaultValue) {
        String value = selectConfigByKey(configKey);
        return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
    }
}
