package cn.qihangerp.erp.notify;

import cn.qihangerp.model.entity.SysAlertChannel;
import cn.qihangerp.service.ISysAlertChannelService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotifierService {

    private final ISysAlertChannelService channelService;
    private final FeishuNotifier feishuNotifier;
    private final DingTalkNotifier dingTalkNotifier;
    private final WeChatNotifier weChatNotifier;

    public boolean notifyAll(String title, String content) {
        List<SysAlertChannel> channels = channelService.list(
                new LambdaQueryWrapper<SysAlertChannel>().eq(SysAlertChannel::getStatus, 1));
        if (channels.isEmpty()) return true;

        boolean allOk = true;
        for (SysAlertChannel ch : channels) {
            try {
                boolean ok = switch (ch.getChannelType()) {
                    case "FEISHU" -> feishuNotifier.notify(ch.getWebhookUrl(), title, content);
                    case "DINGTALK" -> dingTalkNotifier.notify(ch.getWebhookUrl(), ch.getSecret(), title, content);
                    case "WECHAT" -> weChatNotifier.notify(ch.getWebhookUrl(), title, content);
                    default -> false;
                };
                if (!ok) {
                    allOk = false;
                    log.warn("渠道 {} 推送失败", ch.getChannelName());
                }
            } catch (Exception e) {
                allOk = false;
                log.error("渠道 {} 推送异常", ch.getChannelName(), e);
            }
        }
        return allOk;
    }
}
