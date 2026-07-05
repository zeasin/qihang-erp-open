package cn.qihangerp.open.xhs;

import cn.qihangerp.open.common.ApiResultVo;
import cn.qihangerp.open.common.MD5Utils;
import cn.qihangerp.open.common.OkHttpClientHelper;
import cn.qihangerp.open.xhs.response.OrderResponse;
import cn.qihangerp.open.xhs.response.AfterSaleInfoResponse;
import cn.qihangerp.open.xhs.response.GoodsItemInfo;
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
public class xhsOrderApiHelper {

    // ========== 原始 String 方法（已有） ==========

    public static String pullOrderList(String appId, String appSecret, String accessToken, LocalDateTime startTime, LocalDateTime  endTime, Integer pageNo, Integer pageSize) throws IOException {
        String serverUrl = "https://ark.xiaohongshu.com/ark/open_api/v3/common_controller";
        String method = "order.getOrderList";
        Long time = System.currentTimeMillis()/ 1000;
        Map<String, Object> params = new HashMap<>();
        params.put("appId", appId);
        params.put("version","2.0");
        params.put("timestamp", time.toString());
        params.put("accessToken", accessToken);
        params.put("method", method);

        String signString = method+"?appId="+appId+"&timestamp="+time+"&version="+"2.0"+appSecret;
        String sign = MD5Utils.MD5Encode(signString);
        params.put("sign", sign);

        params.put("startTime", startTime.toInstant(ZoneOffset.ofHours(8)).toEpochMilli()/1000);
        params.put("endTime", endTime.toInstant(ZoneOffset.ofHours(8)).toEpochMilli()/1000);
        params.put("timeType", 1);
        params.put("pageNo", pageNo+"");
        params.put("pageSize", pageSize+"");

        String jsonString = JSONObject.toJSONString(params);
        String result =  OkHttpClientHelper.post(serverUrl, jsonString);
        return result;
    }

    public static String getOrderDetail(String appId,String appSecret,String accessToken,String orderId) throws IOException {
        String serverUrl = "https://ark.xiaohongshu.com/ark/open_api/v3/common_controller";
        String method = "order.getOrderDetail";
        Long time = System.currentTimeMillis()/ 1000;
        Map<String, String> params = new HashMap<>();
        params.put("appId", appId);
        params.put("version","2.0");
        params.put("timestamp", time.toString());
        params.put("accessToken", accessToken);
        params.put("method", method);

        String signString = method+"?appId="+appId+"&timestamp="+time+"&version="+"2.0"+appSecret;
        String sign = MD5Utils.MD5Encode(signString);
        params.put("sign", sign);

        params.put("orderId", orderId);

        String jsonString = JSONObject.toJSONString(params);
        String result =  OkHttpClientHelper.post(serverUrl, jsonString);
        return result;
    }

    public static String getOrderReceiverInfo(String appId,String appSecret,String accessToken, String orderId,String openAddressId) throws IOException {
        String serverUrl = "https://ark.xiaohongshu.com/ark/open_api/v3/common_controller";
        String method = "order.getOrderReceiverInfo";
        Long time = System.currentTimeMillis()/ 1000;
        Map<String, Object> params = new HashMap<>();
        params.put("appId", appId);
        params.put("version","2.0");
        params.put("timestamp", time.toString());
        params.put("accessToken", accessToken);
        params.put("method", method);

        String signString = method+"?appId="+appId+"&timestamp="+time.toString()+"&version="+"2.0"+appSecret;
        String sign = MD5Utils.MD5Encode(signString);
        params.put("sign", sign);

        Map<String,String> orderParams = new HashMap<>();
        orderParams.put("openAddressId", openAddressId);
        orderParams.put("orderId", orderId);
        List<Map<String,String>> orderParamsList = new ArrayList<>();
        orderParamsList.add(orderParams);
        params.put("receiverQueries", orderParamsList);
        params.put("isReturn", false);

        String jsonString = JSONObject.toJSONString(params);
        String result =  OkHttpClientHelper.post(serverUrl, jsonString);
        return result;
    }

    // ========== ApiResultVo 包装方法 ==========

    /**
     * 拉取订单列表，返回 ApiResultVo<List<OrderResponse>>
     */
    public static ApiResultVo<OrderResponse> pullOrderListVo(String appId, String appSecret, String accessToken,
                                                             LocalDateTime startTime, LocalDateTime endTime) throws IOException {
        List<OrderResponse> allOrders = new ArrayList<>();
        int pageNo = 1;
        int pageSize = 50;
        boolean hasMore = true;

        while (hasMore) {
            String result = pullOrderList(appId, appSecret, accessToken, startTime, endTime, pageNo, pageSize);
            if (result == null) return ApiResultVo.error(500, "接口返回空");

            JSONObject json = JSONObject.parseObject(result);
            String code = json.getString("code");
            if (!"0".equals(code)) {
                return ApiResultVo.error(code != null ? Integer.parseInt(code) : 500, json.getString("msg"));
            }

            JSONObject data = json.getJSONObject("data");
            if (data != null) {
                JSONArray orderList = data.getJSONArray("orderList");
                if (orderList != null) {
                    List<OrderResponse> pageOrders = orderList.toList(OrderResponse.class);
                    allOrders.addAll(pageOrders);
                }
                // 分页判断
                int currentPage = data.getIntValue("pageNo", 1);
                int totalPage = data.getIntValue("totalPage", 1);
                hasMore = currentPage < totalPage;
                pageNo = currentPage + 1;
            } else {
                hasMore = false;
            }
        }
        return ApiResultVo.success(allOrders.size(), allOrders);
    }

    /**
     * 拉取订单详情，返回 ApiResultVo<OrderResponse>
     */
    public static ApiResultVo<OrderResponse> getOrderDetailVo(String appId, String appSecret, String accessToken, String orderId) throws IOException {
        String result = getOrderDetail(appId, appSecret, accessToken, orderId);
        if (result == null) return ApiResultVo.error(500, "接口返回空");

        JSONObject json = JSONObject.parseObject(result);
        String code = json.getString("code");
        if (!"0".equals(code)) {
            return ApiResultVo.error(code != null ? Integer.parseInt(code) : 500, json.getString("msg"));
        }

        JSONObject data = json.getJSONObject("data");
        if (data == null) return ApiResultVo.error(404, "订单不存在");

        OrderResponse order = data.getObject("order", OrderResponse.class);
        if (order == null) order = data.toJavaObject(OrderResponse.class);
        return ApiResultVo.success(order);
    }
}