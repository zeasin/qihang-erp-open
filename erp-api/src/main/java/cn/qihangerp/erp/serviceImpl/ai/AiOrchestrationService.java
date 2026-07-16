package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.AiConfig;
import cn.qihangerp.service.AiConfigService;
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

@Slf4j
@RequiredArgsConstructor
@Service
public class AiOrchestrationService {

    private final AiConfigService aiConfigService;

    public AiConfig getDefaultConfig() {
        return aiConfigService.getDefaultConfig();
    }

    public ChatClient buildChatClient(AiConfig config, Object... tools) {
        String baseUrl = config.getApiEndpoint()
                .replaceAll("/v1/?$", "")
                .replaceAll("/+$", "");

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

        ChatClient.Builder builder = ChatClient.builder(chatModel);
        if (tools.length > 0) {
            builder.defaultTools(tools);
        }
        return builder.build();
    }

    public ChatClient buildDefaultChatClient(Object... tools) {
        AiConfig config = getDefaultConfig();
        if (config == null) {
            throw new RuntimeException("未配置默认AI模型，请先在AI配置中设置默认模型");
        }
        return buildChatClient(config, tools);
    }
}
