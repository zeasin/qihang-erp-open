package cn.qihangerp.open.kwai;

import cn.qihangerp.open.common.ApiResultVo;
import cn.qihangerp.open.common.SignMethodEnum;
import cn.qihangerp.open.common.SignUtils;
import cn.qihangerp.open.common.OkHttpClientHelper;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import java.net.URLEncoder;
import java.util.*;

/**
 * 快手售后API（修复版：使用 OkHttpClientHelper 发起真实HTTP调用）
 */
public class KwaiRefundApiHelper {

    /**
     * 拉取售后列表
     * @param appKey      快手开放平台appkey
     * @param appSecret   appSecret
     * @param signSecret  签名secret
     * @param token       access_token
     * @param beginTime   开始时间 毫秒时间戳
     * @param endTime     结束时间 毫秒时间戳
     * @return refund list as JSONArray
     */
    public static ApiResultVo<JSONObject> pullRefundList(String appKey, String appSecret, String signSecret, String token,
                                                         Long beginTime, Long endTime) {
        String serverUrl = "https://openapi.kwaixiaodian.com";
        List<JSONObject> allRefunds = new ArrayList<>();
        String pcursor = "";
        boolean hasMore = true;
        int page = 1;

        while (hasMore) {
            Map<String, String> params = new HashMap<>();
            params.put("appkey", appKey);
            params.put("access_token", token);
            params.put("method", "open.seller.order.refund.pcursor.list");

            Map<String, Object> p = new HashMap<>();
            p.put("beginTime", beginTime);
            p.put("endTime", endTime);
            p.put("type", "9");
            p.put("pageSize", 50);
            p.put("currentPage", page);
            p.put("pcursor", pcursor);
            String jsonString = JSONObject.toJSONString(p);
            params.put("param", jsonString);

            try {
                String signParam = SignUtils.sign(params, signSecret, SignMethodEnum.MD5);
                params.put("sign", signParam);
            } catch (Exception e) {
                return ApiResultVo.error(500, "签名失败");
            }

            StringJoiner joiner = new StringJoiner("&");
            params.forEach((key, value) -> {
                try { joiner.add(key + "=" + URLEncoder.encode(value)); } catch (Exception ignored) {}
            });
            String fullUrl = serverUrl + "/open/seller/order/refund/pcursor/list?" + joiner;

            try {
                String resultString = OkHttpClientHelper.get(fullUrl);
                JSONObject result = JSONObject.parseObject(resultString);
                if (result == null) return ApiResultVo.error(500, "接口返回空");

                if (result.getInteger("result") == 1) {
                    Map<String, Object> data = (LinkedHashMap) result.get("data");
                    if (data != null) {
                        List<JSONObject> items = JSONArray.parseArray(JSONObject.toJSONString(data.get("items")), JSONObject.class);
                        if (items != null) allRefunds.addAll(items);
                        Integer totalPage = data.get("totalPage") != null ? Integer.parseInt(data.get("totalPage").toString()) : 1;
                        hasMore = page < totalPage;
                        pcursor = data.get("pcursor") != null ? data.get("pcursor").toString() : "";
                        page++;
                    } else {
                        hasMore = false;
                    }
                } else {
                    return ApiResultVo.error(result.getInteger("result"), result.getString("error_msg"));
                }
            } catch (Exception e) {
                return ApiResultVo.error(500, "接口请求异常:" + e.getMessage());
            }
        }
        return ApiResultVo.success(allRefunds.size(), allRefunds);
    }
}