package cn.qihangerp.erp.controller.ai;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.serviceImpl.ai.AiOrchestrationService;
import cn.qihangerp.erp.serviceImpl.ai.DataTools;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@RestController
@RequestMapping("/api/ai/analysis")
@RequiredArgsConstructor
public class AiAnalysisController {

    private final AiOrchestrationService orchestrationService;
    private final DataTools dataTools;

    @PostMapping
    public AjaxResult analyze(@RequestBody AnalysisRequest req) {
        if (req.getPrompt() == null || req.getPrompt().trim().isEmpty()) {
            return AjaxResult.error("请输入分析需求");
        }

        String systemPrompt = """
                你是一个电商数据分析师，擅长从多维度分析电商运营数据。
                你可以使用以下工具查询实时数据，请根据需要主动调用：
                - getSalesSummary(days)：获取最近N天销售统计
                - getTodaySales()：获取今日销售数据
                - getWaitShipReport()：获取待发货统计
                - getShopList()：获取店铺列表
                - searchGoods(keyword)：搜索商品
                - searchSku(keyword)：搜索SKU

                分析要求：
                1. 先调用相关工具获取数据
                2. 基于真实数据进行分析
                3. 给出数据支撑的结论和建议
                4. 如果没有相关数据，如实说明
                """;

        try {
            ChatClient chatClient = orchestrationService.buildDefaultChatClient(dataTools);
            String result = CompletableFuture.supplyAsync(() ->
                    chatClient.prompt()
                            .system(systemPrompt)
                            .user(req.getPrompt())
                            .call()
                            .content()
            ).get(120, TimeUnit.SECONDS);

            return AjaxResult.success((Object) result);
        } catch (Exception e) {
            log.error("AI分析失败", e);
            return AjaxResult.error("分析失败：" + e.getMessage());
        }
    }

    @lombok.Data
    public static class AnalysisRequest {
        private String prompt;
    }
}
