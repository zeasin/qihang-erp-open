package cn.qihangerp.erp.serviceImpl;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.deepseek.DeepSeekChatModel;
import org.springframework.ai.deepseek.DeepSeekChatOptions;
import org.springframework.ai.deepseek.api.DeepSeekApi;
import org.springframework.ai.model.SimpleApiKey;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

public class InventorySalesAnalyzer {

    private static final String API_KEY = System.getProperty("spring.ai.deepseek.api-key", "");
    private static final String API_URL = System.getProperty("spring.ai.deepseek.base-url", "https://api.deepseek.com");
    private static final String MODEL = System.getProperty("spring.ai.deepseek.model", "deepseek-chat");

    // 你的数据
    private static final String INVENTORY_JSON = "[{\"id\":1,\"goods_title\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"sku_name\":\"白光12W\",\"stock_num\":12},{\"id\":2,\"goods_title\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"sku_name\":\"白光18W\",\"stock_num\":12},{\"id\":3,\"goods_title\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"sku_name\":\"白光24W\",\"stock_num\":12},{\"id\":4,\"goods_title\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"sku_name\":\"双色36W\",\"stock_num\":12}]";

    private static final String SALES_JSON = "[{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":3,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":2,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":4,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":3,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":1,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"},{\"order_num\":\"1\",\"sku_id\":2,\"count\":1,\"item_amount\":29.32,\"order_time\":\"2025-05-24 23:19:51\"}]";

    public static void main(String[] args) {
        try {
            System.out.println("开始分析库存与销售数据...\n");

            // 1. 解析数据
            List<InventoryItem> inventoryList = parseInventoryData();
            List<SalesOrder> salesList = parseSalesData();

            // 2. 分析数据并生成报告
            String analysisResult = analyzeInventoryAndSales(inventoryList, salesList);

            System.out.println("=== AI 分析报告 ===\n");
            System.out.println(analysisResult);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 核心分析方法
     */
    public static String analyzeInventoryAndSales(List<InventoryItem> inventory,
                                                  List<SalesOrder> sales) throws Exception {

        // 1. 数据预处理：按 SKU ID 关联库存和销售数据
        Map<Integer, SkuAnalysis> analysisMap = new HashMap<>();

        // 初始化库存数据
        for (InventoryItem item : inventory) {
            SkuAnalysis analysis = new SkuAnalysis();
            analysis.id = item.id;
            analysis.goodsTitle = item.goods_title;
            analysis.skuName = item.sku_name;
            analysis.stockNum = item.stock_num;
            analysisMap.put(item.id, analysis);
        }

        // 统计销售数据
        for (SalesOrder order : sales) {
            if (analysisMap.containsKey(order.sku_id)) {
                SkuAnalysis analysis = analysisMap.get(order.sku_id);
                analysis.totalSales += order.count;
                analysis.totalRevenue += order.item_amount;
                analysis.orderCount++;

                // 记录销售时间（用于趋势分析）
                analysis.salesTimes.add(order.order_time);
            }
        }

        // 2. 计算关键指标
        for (SkuAnalysis analysis : analysisMap.values()) {
            // 计算日均销量（假设数据是最近30天的）
            analysis.dailyAvgSales = analysis.totalSales / 30.0;

            // 计算可售天数
            if (analysis.dailyAvgSales > 0) {
                analysis.daysOfSupply = analysis.stockNum / analysis.dailyAvgSales;
            } else {
                analysis.daysOfSupply = 999; // 无销售
            }

            // 判断库存状态
            analysis.stockStatus = determineStockStatus(analysis.stockNum, analysis.dailyAvgSales);
        }

        // 3. 构建 AI 分析提示词
        String prompt = buildAnalysisPrompt(analysisMap);

        // 4. 调用 DeepSeek API（Spring AI 2.0）
        return callAi(prompt);
    }

    /**
     * 使用 Spring AI 2.0 调用大模型
     */
    private static String callAi(String prompt) throws Exception {
        // 构建 DeepSeekApi
        String baseUrl = API_URL.replaceAll("/v1/?$", "").replaceAll("/+$", "");
        DeepSeekApi api = DeepSeekApi.builder()
                .baseUrl(baseUrl)
                .apiKey(new SimpleApiKey(API_KEY))
                .completionsPath("/v1/chat/completions")
                .build();

        // 构建 ChatModel
        DeepSeekChatModel chatModel = DeepSeekChatModel.builder()
                .deepSeekApi(api)
                .options(DeepSeekChatOptions.builder()
                        .model(MODEL)
                        .temperature(0.3)
                        .maxTokens(2000)
                        .build())
                .build();

        // 构建 ChatClient 并发起调用
        ChatClient chatClient = ChatClient.builder(chatModel).build();
        return chatClient.prompt()
                .user(prompt)
                .call()
                .content();
    }

    /**
     * 构建 AI 分析提示词
     */
    private static String buildAnalysisPrompt(Map<Integer, SkuAnalysis> analysisMap) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("你是一名专业的电商库存管理专家。请分析以下 LED 灯具产品的库存与销售数据，并提供专业的分析报告和建议：\n\n");

        prompt.append("=== 数据概览 ===\n");
        prompt.append("产品名称：雷士照明 LED 吸顶灯灯芯\n");
        prompt.append("分析时间：").append(LocalDateTime.now()).append("\n\n");

        prompt.append("=== 详细数据 ===\n");
        prompt.append(String.format("%-8s %-12s %-8s %-8s %-12s %-10s %-15s\n",
                "SKU ID", "规格", "库存量", "总销量", "总销售额", "可售天数", "库存状态"));
        prompt.append("-".repeat(80)).append("\n");

        for (SkuAnalysis analysis : analysisMap.values()) {
            prompt.append(String.format("%-8d %-12s %-8d %-8d %-12.2f %-10.1f %-15s\n",
                    analysis.id,
                    analysis.skuName,
                    analysis.stockNum,
                    analysis.totalSales,
                    analysis.totalRevenue,
                    analysis.daysOfSupply,
                    analysis.stockStatus
            ));
        }

        prompt.append("\n=== 分析要求 ===\n");
        prompt.append("请基于以上数据，提供以下分析：\n");
        prompt.append("1. **库存健康度分析**：评估每个SKU的库存状况，识别缺货风险\n");
        prompt.append("2. **销售表现分析**：分析各规格产品的销售情况，找出畅销款和滞销款\n");
        prompt.append("3. **补货建议**：\n");
        prompt.append("   - 哪些SKU需要立即补货？建议补货数量？\n");
        prompt.append("   - 哪些SKU库存过多？建议如何清理？\n");
        prompt.append("   - 建议的安全库存水平\n");
        prompt.append("4. **运营建议**：基于销售模式，给出采购、促销或产品组合建议\n\n");

        prompt.append("请以专业报告格式回复，包含具体数据和理由。");

        return prompt.toString();
    }

    /**
     * 判断库存状态
     */
    private static String determineStockStatus(int stock, double dailySales) {
        if (stock == 0) return "缺货";
        if (dailySales == 0) return "滞销";

        double daysOfSupply = stock / dailySales;

        if (daysOfSupply < 7) return "急需补货";
        if (daysOfSupply < 14) return "需要补货";
        if (daysOfSupply < 30) return "库存正常";
        if (daysOfSupply < 60) return "库存偏高";
        return "库存积压";
    }

    // 数据解析方法
    private static List<InventoryItem> parseInventoryData() {
        return Arrays.asList(
                new InventoryItem(1, "雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康", "白光12W", 12),
                new InventoryItem(2, "雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康", "白光18W", 12),
                new InventoryItem(3, "雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康", "白光24W", 12),
                new InventoryItem(4, "雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康", "双色36W", 12)
        );
    }

    private static List<SalesOrder> parseSalesData() {
        return Arrays.asList(
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 3, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 2, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 4, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 3, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 1, 1, 29.32, "2025-05-24 23:19:51"),
                new SalesOrder("1", 2, 1, 29.32, "2025-05-24 23:19:51")
        );
    }

    // 数据类定义
    static class InventoryItem {
        public int id;
        public String goods_title;
        public String sku_name;
        public int stock_num;

        public InventoryItem(int id, String goods_title, String sku_name, int stock_num) {
            this.id = id;
            this.goods_title = goods_title;
            this.sku_name = sku_name;
            this.stock_num = stock_num;
        }
    }

    static class SalesOrder {
        public String order_num;
        public int sku_id;
        public int count;
        public double item_amount;
        public String order_time;

        public SalesOrder(String order_num, int sku_id, int count, double item_amount, String order_time) {
            this.order_num = order_num;
            this.sku_id = sku_id;
            this.count = count;
            this.item_amount = item_amount;
            this.order_time = order_time;
        }
    }

    static class SkuAnalysis {
        public int id;
        public String goodsTitle;
        public String skuName;
        public int stockNum;
        public int totalSales = 0;
        public double totalRevenue = 0.0;
        public int orderCount = 0;
        public double dailyAvgSales = 0.0;
        public double daysOfSupply = 0.0;
        public String stockStatus = "未知";
        public List<String> salesTimes = new ArrayList<>();
    }
}
