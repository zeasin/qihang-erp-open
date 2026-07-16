package cn.qihangerp.erp.serviceImpl;

import cn.qihangerp.erp.serviceImpl.ai.GoodsTools;
import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.model.vo.SalesDailyVo;
import cn.qihangerp.service.AiConfigService;
import cn.qihangerp.service.OOrderItemService;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.OShopService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.deepseek.DeepSeekChatModel;
import org.springframework.ai.deepseek.DeepSeekChatOptions;
import org.springframework.ai.deepseek.api.DeepSeekApi;
import org.springframework.ai.model.SimpleApiKey;
import org.springframework.http.client.ReactorClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import reactor.netty.http.client.HttpClient;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * AI简报服务 - 为管理者生成智能工作台简报
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiBriefService {

    private final OOrderService orderService;
    private final OOrderItemService orderItemService;
    private final OShopService shopService;
    private final AiConfigService aiConfigService;
    private final GoodsTools goodsTools;

    private final ChatClient.Builder chatClientBuilder;

    /**
     * 生成AI工作台简报
     */
    public AiBriefResponse generateBrief() {
        // 1. 获取数据
        Map<String, Object> todayData = getTodayData();
        List<SalesDailyVo> recentSales = getRecentSales();

        // 2. 检查AI是否可用（优先使用数据库配置）
        AiConfig dbConfig = aiConfigService.getDefaultConfig();
        boolean hasDbConfig = dbConfig != null && dbConfig.getApiKey() != null && !dbConfig.getApiKey().isEmpty();
        String apiKey = System.getProperty("spring.ai.deepseek.api-key", "");
        if (apiKey.isEmpty() || "${DEEPSEEK_API_KEY:}".equals(apiKey)) {
            apiKey = System.getenv("DEEPSEEK_API_KEY");
        }
        boolean hasSysConfig = apiKey != null && !apiKey.isEmpty() && !apiKey.startsWith("${");

        if (!hasDbConfig && !hasSysConfig) {
            // AI不可用，返回纯数据版
            return buildFallbackBrief(todayData, recentSales);
        }

        // 3. 调用AI生成简报
        try {
            return callAiForBrief(todayData, recentSales);
        } catch (Exception e) {
            log.warn("AI简报生成失败，使用本地降级", e);
            return buildFallbackBrief(todayData, recentSales);
        }
    }

    /**
     * 调用DeepSeek生成AI简报
     */
    private ChatClient buildChatClient() {
        AiConfig config = aiConfigService.getDefaultConfig();
        if (config != null && config.getApiEndpoint() != null && config.getApiKey() != null) {
            try {
                String baseUrl = config.getApiEndpoint().replaceAll("/v1/?$", "").replaceAll("/+$", "");
                var httpClient = HttpClient.create()
                        .responseTimeout(Duration.ofSeconds(120));
                var factory = new ReactorClientHttpRequestFactory(httpClient);
                factory.setReadTimeout(Duration.ofSeconds(120));
                DeepSeekApi api = DeepSeekApi.builder()
                        .baseUrl(baseUrl)
                        .apiKey(new SimpleApiKey(config.getApiKey()))
                        .completionsPath("/v1/chat/completions")
                        .restClientBuilder(RestClient.builder().requestFactory(factory))
                        .build();
                DeepSeekChatModel chatModel = DeepSeekChatModel.builder()
                        .deepSeekApi(api)
                        .options(DeepSeekChatOptions.builder()
                                .model(config.getModelName())
                                .build())
                        .build();
                return ChatClient.builder(chatModel)
                        .defaultTools(goodsTools)
                        .build();
            } catch (Exception e) {
                log.warn("动态ChatClient构建失败，使用默认", e);
            }
        }
        return chatClientBuilder.build();
    }

    private AiBriefResponse callAiForBrief(Map<String, Object> todayData, List<SalesDailyVo> recentSales) {
        ChatClient chatClient = buildChatClient();

        // 构建销售趋势文本
        StringBuilder trendText = new StringBuilder();
        if (recentSales != null && recentSales.size() >= 2) {
            trendText.append("近7日销售数据（按日期倒序）：\n");
            for (int i = 0; i < recentSales.size(); i++) {
                SalesDailyVo day = recentSales.get(i);
                trendText.append("  ").append(day.getDate())
                        .append("：销售额").append(day.getAmount())
                        .append("元，订单数").append(day.getCount()).append("\n");
            }
        }

        String now = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String prompt = """
                你是一个电商运营助手，请根据以下数据生成今日工作台简报。

                当前时间：%s
                今日数据：
                - 今日销售额：%s 元
                - 今日订单数：%s 单
                - 待发货：%s 单
                - 店铺总数：%s 个

                近7日销售趋势：
                %s

                请按以下JSON格式返回，不要带markdown标记：
                {
                    "greeting": "根据当前时间段给出问候语（如当前20点应说'晚上好'）",
                    "summary": "一句话说清楚今日核心情况（不超过20字）",
                    "trend": "销售趋势一句话（环比变化，哪个表现突出，不超过50字）",
                    "priorities": [
                        {
                            "level": "high/medium/low",
                            "category": "发货/退款/库存/售后",
                            "title": "问题标题（一句话）",
                            "detail": "具体描述（不超过30字）",
                            "action": "按钮文字",
                            "link": "跳转路径",
                            "count": 8
                        }
                    ],
                    "quickStats": {
                        "salesVolume": "12,580",
                        "salesTrend": "+12.5%%",
                        "orderCount": 302,
                        "waitShip": 50,
                        "refundRate": "暂无数据"
                    }
                }

                注意：
                - priorities最多3条，按紧急程度排序
                - 没有数据支撑的不要编造
                - quickStats中salesTrend对比昨日
                """.formatted(
                now,
                todayData.get("salesVolume"),
                todayData.get("orderCount"),
                todayData.get("waitShip"),
                todayData.get("shopCount"),
                trendText.toString()
        );

        try {
            String response = CompletableFuture.supplyAsync(() ->
                            chatClient.prompt()
                                    .user(prompt)
                                    .call()
                                    .content()
                    )
                    .get(30, TimeUnit.SECONDS);
            return parseAiResponse(response, todayData);
        } catch (TimeoutException e) {
            log.warn("AI接口响应超时，使用降级数据", e);
            return buildFallbackBrief(todayData, recentSales);
        } catch (Exception e) {
            log.warn("AI调用失败，使用降级", e);
            return buildFallbackBrief(todayData, recentSales);
        }
    }

    /**
     * 解析AI返回的JSON
     */
    private AiBriefResponse parseAiResponse(String response, Map<String, Object> todayData) {
        String json = response;
        if (json.contains("{")) {
            json = json.substring(json.indexOf("{"), json.lastIndexOf("}") + 1);
        }

        try {
            var obj = com.alibaba.fastjson2.JSONObject.parseObject(json);
            AiBriefResponse brief = new AiBriefResponse();
            brief.setGreeting(obj.getString("greeting"));
            brief.setSummary(obj.getString("summary"));
            brief.setTrend(obj.getString("trend"));

            var stats = obj.getJSONObject("quickStats");
            if (stats != null) {
                var qs = new QuickStats();
                qs.setSalesVolume(stats.getString("salesVolume"));
                qs.setSalesTrend(stats.getString("salesTrend"));
                qs.setOrderCount(stats.getInteger("orderCount"));
                qs.setWaitShip(stats.getInteger("waitShip"));
                qs.setRefundRate(stats.getString("refundRate"));
                brief.setQuickStats(qs);
            }

            var priArr = obj.getJSONArray("priorities");
            if (priArr != null) {
                brief.setPriorities(priArr.toList(Priority.class));
            }

            return brief;
        } catch (Exception e) {
            throw new RuntimeException("JSON解析失败", e);
        }
    }

    /**
     * 降级方案
     */
    private AiBriefResponse buildFallbackBrief(Map<String, Object> todayData, List<SalesDailyVo> recentSales) {
        AiBriefResponse brief = new AiBriefResponse();
        brief.setGreeting("欢迎使用");

        QuickStats qs = new QuickStats();
        qs.setSalesVolume(String.valueOf(todayData.get("salesVolume")));
        qs.setOrderCount(((Number)todayData.get("orderCount")).intValue());
        qs.setWaitShip(((Number)todayData.get("waitShip")).intValue());
        brief.setQuickStats(qs);

        if (!isApiKeyConfigured()) {
            brief.setAiAvailable(false);
            brief.setSummary("AI分析未配置");
            brief.setTrend("配置DeepSeek API Key后可获得AI分析");

            Number waitShip = (Number) todayData.get("waitShip");
            if (waitShip != null && waitShip.intValue() > 0) {
                Priority p = new Priority();
                p.setLevel("medium");
                p.setCategory("发货");
                p.setTitle(waitShip.intValue() + "单待发货");
                p.setDetail("建议尽快处理");
                p.setAction("去发货");
                p.setLink("/shipping/manual_ship");
                p.setCount(waitShip.intValue());
                brief.setPriorities(List.of(p));
            }
            return brief;
        }

        brief.setAiAvailable(true);
        brief.setSummary("今日数据已就绪");
        brief.setTrend("AI分析暂不可用，系统自动生成概要");

        Number waitShip = (Number) todayData.get("waitShip");
        if (waitShip != null && waitShip.intValue() > 0) {
            Priority p = new Priority();
            p.setLevel("medium");
            p.setCategory("发货");
            p.setTitle(waitShip.intValue() + "单待发货");
            p.setDetail("请安排处理");
            p.setAction("去发货");
            p.setLink("/shipping/manual_ship");
            p.setCount(waitShip.intValue());
            brief.setPriorities(List.of(p));
        }

        return brief;
    }

    private boolean isApiKeyConfigured() {
        String apiKey = System.getProperty("spring.ai.deepseek.api-key", "");
        if (apiKey.isEmpty() || apiKey.startsWith("${")) {
            apiKey = System.getenv("DEEPSEEK_API_KEY");
        }
        return apiKey != null && !apiKey.isEmpty() && !apiKey.startsWith("${");
    }

    /**
     * 获取今日数据
     */
    private Map<String, Object> getTodayData() {
        Long shopCount = shopService.list().stream().count();
        SalesDailyVo todaySales = orderService.getTodaySalesDaily(0L);
        Number waitShip = orderService.getWaitShipOrderAllCount(0L);

        return Map.of(
                "salesVolume", todaySales != null && todaySales.getAmount() != null ? todaySales.getAmount() : 0,
                "orderCount", todaySales != null && todaySales.getCount() != null ? todaySales.getCount().doubleValue() : 0,
                "waitShip", waitShip != null ? waitShip.doubleValue() : 0,
                "shopCount", shopCount != null ? shopCount.doubleValue() : 0
        );
    }

    /**
     * 获取近期销售数据
     */
    private List<SalesDailyVo> getRecentSales() {
        return orderService.salesDaily();
    }

    // ====== 内部类 ======

    @lombok.Data
    public static class AiBriefResponse {
        private String greeting = "";
        private String summary = "";
        private String trend = "";
        private boolean aiAvailable = true;
        private QuickStats quickStats;
        private List<Priority> priorities = List.of();
    }

    @lombok.Data
    public static class QuickStats {
        private String salesVolume = "—";
        private String salesTrend = "";
        private Integer orderCount = 0;
        private Integer waitShip = 0;
        private String refundRate = "—";
    }

    @lombok.Data
    public static class Priority {
        private String level;    // high/medium/low
        private String category; // 发货/退款/库存/售后
        private String title;    // 问题标题
        private String detail;   // 具体描述
        private String action;   // 按钮文字
        private String link;     // 跳转路径
        private Integer count;   // 数量
    }
}