package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.mapper.SysAlertChannelMapper;
import cn.qihangerp.model.entity.SysAlertChannel;
import cn.qihangerp.service.ISysAlertChannelService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SysAlertChannelServiceImpl extends ServiceImpl<SysAlertChannelMapper, SysAlertChannel>
        implements ISysAlertChannelService {
}
