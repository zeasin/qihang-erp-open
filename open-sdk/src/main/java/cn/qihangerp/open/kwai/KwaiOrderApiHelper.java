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
 * 快手订单API（修复版：使用 OkHttpClientHelper 发起真实HTTP调用）
 */
public class KwaiOrderApiHelper {

    /**
     * 拉取订单列表
     * @param appKey      快手开放平台appkey
     * @param appSecret   appSecret
     * @param signSecret  签名secret
     * @param token       access_token
     * @param beginTime   开始时间 毫秒时间戳
     * @param endTime     结束时间 毫秒时间戳
     * @return order list as JSONArray
     */
    public static ApiResultVo<JSONObject> pullOrderList(String appKey, String appSecret, String signSecret, String token,
                                                        Long beginTime, Long endTime) {
        String serverUrl = "https://openapi.kwaixiaodian.com";
        List<JSONObject> allOrders = new ArrayList<>();
        String cursor = "";
        boolean hasMore = true;

        while (hasMore) {
            Map<String, String> params = new HashMap<>();
            params.put("appkey", appKey);
            params.put("access_token", token);
            params.put("method", "open.order.cursor.list");

            Map<String, Object> p = new HashMap<>();
            p.put("orderViewStatus", 1);
            p.put("pageSize", 100);
            p.put("queryType", 2);
            p.put("beginTime", beginTime);
            p.put("endTime", endTime);
            p.put("cursor", cursor);
            String jsonString = JSONObject.toJSONString(p);
            params.put("param", jsonString);

            try {
                String signParam = SignUtils.sign(params, signSecret, SignMethodEnum.MD5);
                params.put("sign", signParam);
            } catch (Exception e) {
                return ApiResultVo.error(500, "签名失败");
            }

            // 构建URL
            StringJoiner joiner = new StringJoiner("&");
            params.forEach((key, value) -> {
                try { joiner.add(key + "=" + URLEncoder.encode(value)); } catch (Exception ignored) {}
            });
            String fullUrl = serverUrl + "/open/order/cursor/list?" + joiner;

            try {
                String resultString = OkHttpClientHelper.get(fullUrl);
                JSONObject result = JSONObject.parseObject(resultString);
                if (result == null) return ApiResultVo.error(500, "接口返回空");

                if (result.getInteger("result") == 1) {
                    Map<String, Object> data = (LinkedHashMap) result.get("data");
                    if (data != null) {
                        List<JSONObject> orders = JSONArray.parseArray(JSONObject.toJSONString(data.get("orderList")), JSONObject.class);
                        if (orders != null) allOrders.addAll(orders);
                        cursor = data.get("cursor") != null ? data.get("cursor").toString() : "";
                        if ("no".equals(cursor)) hasMore = false;
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
        return ApiResultVo.success(allOrders.size(), allOrders);
    }

    /**
     * 拉取订单详情
     * @param appKey      快手开放平台appkey
     * @param appSecret   appSecret
     * @param signSecret  签名secret
     * @param token       access_token
     * @param orderId     快手订单号
     * @return order detail as JSONObject
     */
    public static ApiResultVo<JSONObject> pullOrderDetail(String appKey, String appSecret, String signSecret, String token, String orderId) {
        String serverUrl = "https://openapi.kwaixiaodian.com";
        Map<String, String> params = new HashMap<>();
        params.put("appkey", appKey);
        params.put("access_token", token);
        params.put("method", "open.order.detail.get");

        Map<String, Object> p = new HashMap<>();
        p.put("orderId", orderId);
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
        String fullUrl = serverUrl + "/open/order/detail/get?" + joiner;

        try {
            String resultString = OkHttpClientHelper.get(fullUrl);
            JSONObject result = JSONObject.parseObject(resultString);
            if (result == null) return ApiResultVo.error(500, "接口返回空");
            if (result.getInteger("result") == 1) {
                Map<String, Object> data = (LinkedHashMap) result.get("data");
                if (data != null) {
                    JSONObject order = JSONObject.parseObject(JSONObject.toJSONString(data.get("orderDetail")));
                    if (order != null) return ApiResultVo.success(order);
                }
                return ApiResultVo.error(404, "订单不存在");
            } else {
                return ApiResultVo.error(result.getInteger("result"), result.getString("error_msg"));
            }
        } catch (Exception e) {
            return ApiResultVo.error(500, "接口请求异常:" + e.getMessage());
        }
    }
}