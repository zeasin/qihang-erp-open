package cn.qihangerp.open.xhs;

import cn.qihangerp.open.common.ApiResultVo;
import cn.qihangerp.open.common.MD5Utils;
import cn.qihangerp.open.common.OkHttpClientHelper;
import cn.qihangerp.open.xhs.response.AfterSaleInfoResponse;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
public class xhsRefundApiHelper {

    // ========== 原始 String 方法 ==========

    public static String pullRefundList(String appId, String appSecret, String accessToken, LocalDateTime startTime, LocalDateTime endTime, Integer pageNo, Integer pageSize) throws IOException {
        String serverUrl = "https://ark.xiaohongshu.com/ark/open_api/v3/common_controller";
        String method = "afterSale.listAfterSaleInfos";
        Long time = System.currentTimeMillis() / 1000;
        Map<String, Object> params = new HashMap<>();
        params.put("appId", appId);
        params.put("version", "2.0");
        params.put("timestamp", time.toString());
        params.put("accessToken", accessToken);
        params.put("method", method);

        String signString = method + "?appId=" + appId + "&timestamp=" + time + "&version=" + "2.0" + appSecret;
        String sign = MD5Utils.MD5Encode(signString);
        params.put("sign", sign);

        params.put("startTime", startTime.toInstant(ZoneOffset.ofHours(8)).toEpochMilli());
        params.put("endTime", endTime.toInstant(ZoneOffset.ofHours(8)).toEpochMilli());
        params.put("timeType", 1);
        params.put("pageNo", pageNo + "");
        params.put("pageSize", pageSize + "");

        String jsonString = JSONObject.toJSONString(params);
        return OkHttpClientHelper.post(serverUrl, jsonString);
    }

    public static String getRefundDetail(String appId, String appSecret, String accessToken, String returnsId) throws IOException {
        String serverUrl = "https://ark.xiaohongshu.com/ark/open_api/v3/common_controller";
        String method = "afterSale.getAfterSaleInfo";
        Long time = System.currentTimeMillis() / 1000;
        Map<String, String> params = new HashMap<>();
        params.put("appId", appId);
        params.put("version", "2.0");
        params.put("timestamp", time.toString());
        params.put("accessToken", accessToken);
        params.put("method", method);

        String signString = method + "?appId=" + appId + "&timestamp=" + time + "&version=" + "2.0" + appSecret;
        String sign = MD5Utils.MD5Encode(signString);
        params.put("sign", sign);

        params.put("returnsId", returnsId);

        String jsonString = JSONObject.toJSONString(params);
        return OkHttpClientHelper.post(serverUrl, jsonString);
    }

    // ========== ApiResultVo 包装方法 ==========

    /**
     * 拉取售后列表，返回 ApiResultVo<List<AfterSaleInfoResponse>>
     */
    public static ApiResultVo<AfterSaleInfoResponse> pullRefundListVo(String appId, String appSecret, String accessToken,
                                                                       LocalDateTime startTime, LocalDateTime endTime) throws IOException {
        List<AfterSaleInfoResponse> allRefunds = new ArrayList<>();
        int pageNo = 1;
        int pageSize = 50;
        boolean hasMore = true;

        while (hasMore) {
            String result = pullRefundList(appId, appSecret, accessToken, startTime, endTime, pageNo, pageSize);
            if (result == null) return ApiResultVo.error(500, "接口返回空");

            JSONObject json = JSONObject.parseObject(result);
            String code = json.getString("code");
            if (!"0".equals(code)) {
                return ApiResultVo.error(code != null ? Integer.parseInt(code) : 500, json.getString("msg"));
            }

            JSONObject data = json.getJSONObject("data");
            if (data != null) {
                JSONArray refundList = data.getJSONArray("afterSaleList");
                if (refundList == null) refundList = data.getJSONArray("list");
                if (refundList != null) {
                    List<AfterSaleInfoResponse> pageRefunds = refundList.toList(AfterSaleInfoResponse.class);
                    allRefunds.addAll(pageRefunds);
                }
                int currentPage = data.getIntValue("pageNo", 1);
                int totalPage = data.getIntValue("totalPage", 1);
                hasMore = currentPage < totalPage;
                pageNo = currentPage + 1;
            } else {
                hasMore = false;
            }
        }
        return ApiResultVo.success(allRefunds.size(), allRefunds);
    }

    /**
     * 拉取售后详情，返回 ApiResultVo<AfterSaleInfoResponse>
     */
    public static ApiResultVo<AfterSaleInfoResponse> getRefundDetailVo(String appId, String appSecret, String accessToken, String returnsId) throws IOException {
        String result = getRefundDetail(appId, appSecret, accessToken, returnsId);
        if (result == null) return ApiResultVo.error(500, "接口返回空");

        JSONObject json = JSONObject.parseObject(result);
        String code = json.getString("code");
        if (!"0".equals(code)) {
            return ApiResultVo.error(code != null ? Integer.parseInt(code) : 500, json.getString("msg"));
        }

        JSONObject data = json.getJSONObject("data");
        if (data == null) return ApiResultVo.error(404, "售后不存在");

        AfterSaleInfoResponse afterSale = data.getObject("afterSaleInfo", AfterSaleInfoResponse.class);
        if (afterSale == null) afterSale = data.toJavaObject(AfterSaleInfoResponse.class);
        return ApiResultVo.success(afterSale);
    }
}