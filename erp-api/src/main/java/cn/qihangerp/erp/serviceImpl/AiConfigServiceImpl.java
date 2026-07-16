package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.mapper.AiConfigMapper;
import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.service.AiConfigService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class AiConfigServiceImpl extends ServiceImpl<AiConfigMapper, AiConfig> implements AiConfigService {

    @Override
    public AiConfig getDefaultConfig() {
        return lambdaQuery()
                .eq(AiConfig::getIsDefault, 1)
                .eq(AiConfig::getIsEnabled, 1)
                .one();
    }

    @Transactional
    @Override
    public boolean setDefault(Long id) {
        lambdaUpdate()
            .eq(AiConfig::getIsDefault, 1)
            .set(AiConfig::getIsDefault, 0)
            .update();
        // 设置新的默认
        AiConfig config = new AiConfig();
        config.setId(id);
        config.setIsDefault(1);
        return updateById(config);
    }
}
