package cn.qihangerp.erp.controller.sys;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.service.MinioStorageService;
import cn.qihangerp.model.entity.SysConfig;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.SysConfigService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * MinIO 对象存储配置。
 *
 * <p>配置实际保存在 sys_config 表中，本接口只对外暴露这 4 个字段，
 * 保存时「有则改、无则增」，后台页面无需关心参数键名。</p>
 *
 * @author qilip
 */
@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/sys-api/system/minio/config")
public class MinioConfigController extends BaseController {

    private final SysConfigService configService;
    private final MinioStorageService minioStorageService;

    @Data
    public static class MinioConfigVo {
        private String endpoint;
        private String accessKey;
        private String secretKey;
        private String bucket;
        /** 4 项配置是否都已填写 */
        private boolean configured;
    }

    /**
     * 读取当前 MinIO 配置
     */
    @GetMapping
    public AjaxResult get() {
        MinioConfigVo vo = new MinioConfigVo();
        vo.setEndpoint(value(MinioStorageService.KEY_ENDPOINT));
        vo.setAccessKey(value(MinioStorageService.KEY_ACCESS_KEY));
        vo.setSecretKey(value(MinioStorageService.KEY_SECRET_KEY));
        vo.setBucket(value(MinioStorageService.KEY_BUCKET));
        vo.setConfigured(StringUtils.hasText(vo.getEndpoint()) && StringUtils.hasText(vo.getAccessKey())
                && StringUtils.hasText(vo.getSecretKey()) && StringUtils.hasText(vo.getBucket()));
        return success(vo);
    }

    /**
     * 保存 MinIO 配置：先验证连接并创建桶，成功后「已存在则更新，不存在则新增」写入配置。
     */
    @PutMapping
    public AjaxResult save(@RequestBody MinioConfigVo vo) {
        if (vo == null || !StringUtils.hasText(vo.getEndpoint()) || !StringUtils.hasText(vo.getAccessKey())
                || !StringUtils.hasText(vo.getSecretKey()) || !StringUtils.hasText(vo.getBucket())) {
            return error("请完整填写服务地址、访问密钥、秘密密钥和存储桶");
        }

        String endpoint = vo.getEndpoint().trim();
        String accessKey = vo.getAccessKey().trim();
        String secretKey = vo.getSecretKey().trim();
        String bucket = vo.getBucket().trim();

        // 验证 connectivity 并确保桶存在（桶不存在会立即创建），失败时返回友好提示而不是 500
        try {
            minioStorageService.ensureBucket(endpoint, accessKey, secretKey, bucket);
        } catch (Exception e) {
            log.error("MinIO 连接或创建桶失败, endpoint={}, bucket={}", endpoint, bucket, e);
            return error("连接 MinIO 或创建存储桶失败：" + shortError(e));
        }

        saveOrUpdate("MinIO 服务地址", MinioStorageService.KEY_ENDPOINT, endpoint,
                "图片存储 MinIO 服务地址，Docker 环境用 http://minio:9000");
        saveOrUpdate("MinIO 访问密钥", MinioStorageService.KEY_ACCESS_KEY, accessKey,
                "MinIO Access Key");
        saveOrUpdate("MinIO 秘密密钥", MinioStorageService.KEY_SECRET_KEY, secretKey,
                "MinIO Secret Key");
        saveOrUpdate("MinIO 存储桶", MinioStorageService.KEY_BUCKET, bucket,
                "存放图片的私有桶名，需保持私有（不开放匿名读）");
        return success();
    }

    /** 提取 MinIO 异常里可读性较好的信息（MinIO 常把整个 XML 错误塞进 message） */
    private String shortError(Throwable e) {
        Throwable root = e;
        while (root.getCause() != null && root.getCause() != root) {
            root = root.getCause();
        }
        String msg = root.getMessage();
        if (!StringUtils.hasText(msg)) {
            msg = e.getClass().getSimpleName();
        }
        Matcher matcher = Pattern.compile("<Message>(.*?)</Message>", Pattern.DOTALL).matcher(msg);
        if (matcher.find()) {
            msg = matcher.group(1);
        }
        msg = msg.replaceAll("\\s+", " ").trim();
        return msg.length() > 200 ? msg.substring(0, 200) + "..." : msg;
    }

    private String value(String key) {
        String value = configService.selectConfigByKey(key);
        return value == null ? "" : value;
    }

    /** 有则改、无则增 */
    private void saveOrUpdate(String name, String key, String value, String remark) {
        SysConfig config = configService.getOne(
                new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, key));
        if (config == null) {
            SysConfig insert = new SysConfig();
            insert.setConfigName(name);
            insert.setConfigKey(key);
            insert.setConfigValue(value);
            insert.setConfigType("Y");
            insert.setRemark(remark);
            insert.setCreateBy(getUsername());
            insert.setCreateTime(LocalDateTime.now());
            configService.save(insert);
        } else {
            config.setConfigValue(value);
            config.setUpdateBy(getUsername());
            config.setUpdateTime(LocalDateTime.now());
            configService.updateById(config);
        }
    }
}
