package cn.qihangerp.erp.notify;

import cn.qihangerp.utils.http.OkHttpClientHelper;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
public class WeChatNotifier {

    public boolean notify(String webhook, String title, String content) {
        try {
            JSONObject markdown = new JSONObject();
            markdown.put("content", "## " + title + "\n" + content);

            JSONObject body = new JSONObject();
            body.put("msgtype", "markdown");
            body.put("markdown", markdown);

            String result = OkHttpClientHelper.post(webhook, body.toJSONString());
            boolean ok = result != null && result.contains("\"errcode\":0");
            if (!ok) log.warn("企微推送返回异常: {}", result);
            return ok;
        } catch (Exception e) {
            log.error("企微推送失败", e);
            return false;
        }
    }
}
