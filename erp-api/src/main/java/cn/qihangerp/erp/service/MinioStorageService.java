package cn.qihangerp.erp.service;

import cn.qihangerp.service.SysConfigService;
import io.minio.BucketExistsArgs;
import io.minio.GetObjectArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

/**
 * MinIO 对象存储服务。
 *
 * <p>连接参数统一从系统配置表 sys_config 读取（配置键见下方常量），便于在后台
 * 「系统管理 - 参数配置」中集中维护，不再依赖 classpath 下的 config.properties。</p>
 *
 * <p>存储桶保持私有：<b>不设置任何匿名读策略</b>，外部无法直接通过 MinIO 地址访问对象，
 * 所有图片读取都必须经过 {@code ImageUploadController} 的预览接口中转。</p>
 *
 * @author qilip
 */
@Slf4j
@Service
public class MinioStorageService {

    /** MinIO 服务地址，如 http://localhost:9000 或 http://minio:9000 */
    public static final String KEY_ENDPOINT = "minio.endpoint";
    /** 访问密钥（Access Key） */
    public static final String KEY_ACCESS_KEY = "minio.accessKey";
    /** 秘密密钥（Secret Key） */
    public static final String KEY_SECRET_KEY = "minio.secretKey";
    /** 私有存储桶名称 */
    public static final String KEY_BUCKET = "minio.bucket";

    @Autowired
    private SysConfigService sysConfigService;

    /** MinIO 客户端与桶名的组合，每次调用时按最新配置构建，保证改配置后立即生效 */
    private record MinioContext(MinioClient client, String bucket) {
    }

    /**
     * 读取并校验 MinIO 连接配置，构建客户端。
     * 配置来自 sys_config，每次都重新读取，因此后台改配置无需重启服务。
     */
    private MinioContext context() {
        String endpoint = config(KEY_ENDPOINT);
        String accessKey = config(KEY_ACCESS_KEY);
        String secretKey = config(KEY_SECRET_KEY);
        String bucket = config(KEY_BUCKET);

        if (!StringUtils.hasText(endpoint) || !StringUtils.hasText(accessKey)
                || !StringUtils.hasText(secretKey) || !StringUtils.hasText(bucket)) {
            throw new IllegalStateException("请先在【系统管理 - 参数配置】中完整配置 MinIO 参数（minio.*）");
        }

        MinioClient client = MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
        return new MinioContext(client, bucket);
    }

    private String config(String key) {
        String value = sysConfigService.selectConfigByKey(key);
        return value == null ? null : value.trim();
    }

    /**
     * 上传文件到私有桶。
     *
     * @param file        上传的文件
     * @param objectName  对象名（由控制器生成，不含原始文件名，避免路径注入）
     * @param contentType 经过白名单校验的 MIME 类型
     * @return 实际写入的对象名
     */
    public String upload(MultipartFile file, String objectName, String contentType) {
        MinioContext ctx = context();
        try {
            // 桶不存在则自动创建（无需单独 init 容器）；MinIO 新桶默认私有，不调用 setBucketPolicy
            ensureBucketExists(ctx.client(), ctx.bucket());

            try (InputStream inputStream = file.getInputStream()) {
                ctx.client().putObject(PutObjectArgs.builder()
                        .bucket(ctx.bucket())
                        .object(objectName)
                        .contentType(contentType)
                        .stream(inputStream, file.getSize(), -1)
                        .build());
            }
            log.info("图片已上传至 MinIO: {}/{}", ctx.bucket(), objectName);
            return objectName;
        } catch (Exception e) {
            log.error("MinIO 上传失败, bucket={}, objectName={}", ctx.bucket(), objectName, e);
            throw new IllegalStateException("图片上传失败，请检查 MinIO 配置、桶权限或网络连接", e);
        }
    }

    /**
     * 用「配置页面上刚填的参数」验证 MinIO 连接并确保桶存在。
     *
     * <p>供 MinioConfigController 保存配置时调用：这样用户填入新桶名后，
     * 点保存就能立即验证连接并创建桶，而不必等到第一次上传图片。</p>
     *
     * @throws Exception 连接失败、凭据错误或建桶失败时抛出，由调用方转成友好提示
     */
    public void ensureBucket(String endpoint, String accessKey, String secretKey, String bucket) throws Exception {
        if (!StringUtils.hasText(endpoint) || !StringUtils.hasText(accessKey)
                || !StringUtils.hasText(secretKey) || !StringUtils.hasText(bucket)) {
            throw new IllegalArgumentException("MinIO 配置不完整");
        }
        MinioClient client = MinioClient.builder()
                .endpoint(endpoint.trim())
                .credentials(accessKey.trim(), secretKey.trim())
                .build();
        ensureBucketExists(client, bucket.trim());
    }

    /** 桶不存在则创建；并发情况下再确认一次。MinIO 新桶默认私有 */
    private void ensureBucketExists(MinioClient client, String bucket) throws Exception {
        if (client.bucketExists(BucketExistsArgs.builder().bucket(bucket).build())) {
            return;
        }
        try {
            client.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
            log.info("已创建 MinIO 私有桶: {}", bucket);
        } catch (Exception e) {
            // 并发首次创建时可能已被其它请求建好，再确认一次即可
            if (!client.bucketExists(BucketExistsArgs.builder().bucket(bucket).build())) {
                throw e;
            }
        }
    }

    /**
     * 从私有桶读取对象，供预览接口中转使用。
     * <b>调用方必须关闭返回的输入流。</b>
     *
     * @param objectName 对象名
     * @return 对象内容输入流
     */
    public InputStream getObject(String objectName) {
        MinioContext ctx = context();
        try {
            return ctx.client().getObject(GetObjectArgs.builder()
                    .bucket(ctx.bucket())
                    .object(objectName)
                    .build());
        } catch (Exception e) {
            log.error("MinIO 读取失败, bucket={}, objectName={}", ctx.bucket(), objectName, e);
            throw new IllegalStateException("图片读取失败", e);
        }
    }

    /**
     * 删除对象（预留给后续图片替换/清理逻辑使用）。
     *
     * @param objectName 对象名
     */
    public void remove(String objectName) {
        MinioContext ctx = context();
        try {
            ctx.client().removeObject(RemoveObjectArgs.builder()
                    .bucket(ctx.bucket())
                    .object(objectName)
                    .build());
            log.info("图片已从 MinIO 删除: {}/{}", ctx.bucket(), objectName);
        } catch (Exception e) {
            log.error("MinIO 删除失败, bucket={}, objectName={}", ctx.bucket(), objectName, e);
            throw new IllegalStateException("图片删除失败", e);
        }
    }
}
