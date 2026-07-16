package cn.qihangerp.service;

import cn.qihangerp.model.entity.AiConfig;
import com.baomidou.mybatisplus.extension.service.IService;

public interface AiConfigService extends IService<AiConfig> {
    boolean setDefault(Long id);
}
