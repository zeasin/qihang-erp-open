package cn.qihangerp.erp.notify;

import cn.qihangerp.utils.http.OkHttpClientHelper;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
public class FeishuNotifier {

    public boolean notify(String webhook, String title, String content) {
        try {
            JSONObject body = new JSONObject();
            body.put("msg_type", "text");
            body.put("content", new JSONObject(Map.of("text", title + "\n\n" + content)));

            String result = OkHttpClientHelper.post(webhook, body.toJSONString());
            boolean ok = result != null && (result.contains("\"code\":0") || result.contains("\"StatusCode\":0"));
            if (!ok) log.warn("飞书推送返回异常: {}", result);
            return ok;
        } catch (Exception e) {
            log.error("飞书推送失败", e);
            return false;
        }
    }
}
