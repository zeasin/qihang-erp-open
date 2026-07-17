package cn.qihangerp.erp.notify;

import cn.qihangerp.utils.http.OkHttpClientHelper;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

@Slf4j
@Component
public class DingTalkNotifier {

    public boolean notify(String webhook, String secret, String title, String content) {
        try {
            long timestamp = System.currentTimeMillis();
            String sign = "";

            if (StringUtils.hasText(secret)) {
                String stringToSign = timestamp + "\n" + secret;
                Mac mac = Mac.getInstance("HmacSHA256");
                mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
                byte[] signData = mac.doFinal(stringToSign.getBytes(StandardCharsets.UTF_8));
                sign = URLEncoder.encode(Base64.getEncoder().encodeToString(signData), "UTF-8");
            }

            String url = webhook + (webhook.contains("?") ? "&" : "?")
                    + "timestamp=" + timestamp + "&sign=" + sign;

            JSONObject body = new JSONObject();
            body.put("msgtype", "markdown");
            body.put("markdown", new JSONObject(Map.of("title", title, "text", "## " + title + "\n\n" + content)));

            String result = OkHttpClientHelper.post(url, body.toJSONString());
            boolean ok = result != null && result.contains("\"ok\"");
            if (!ok) log.warn("钉钉推送返回异常: {}", result);
            return ok;
        } catch (Exception e) {
            log.error("钉钉推送失败", e);
            return false;
        }
    }
}
