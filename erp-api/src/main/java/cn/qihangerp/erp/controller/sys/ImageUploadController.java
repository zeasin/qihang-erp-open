package cn.qihangerp.erp.controller.sys;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.erp.service.MinioStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 图片上传与预览控制器。
 *
 * <p>上传：文件保存到 MinIO 私有桶（配置在 sys_config 中），返回指向本服务预览接口的相对地址。</p>
 * <p>预览：从 MinIO 读取对象并通过本服务中转输出，浏览器无需直连 MinIO，桶也无需公开读权限。</p>
 *
 * @author qilip
 */
@RestController
public class ImageUploadController {

    /** 单张图片最大 10MB，防止超大文件打满存储 */
    private static final long MAX_FILE_SIZE = 10L * 1024 * 1024;

    /** 允许的图片扩展名 -> 图片 MIME 类型（只认白名单，禁止上传脚本等危险文件） */
    private static final Map<String, String> MIME_BY_EXT = new HashMap<>();

    static {
        MIME_BY_EXT.put("gif", "image/gif");
        MIME_BY_EXT.put("jpg", "image/jpeg");
        MIME_BY_EXT.put("jpeg", "image/jpeg");
        MIME_BY_EXT.put("png", "image/png");
    }

    /** 对象名格式校验：只接受本服务生成的「前缀_日期_UUID.扩展名」，防止路径穿越与任意对象读取 */
    private static final Pattern OBJECT_NAME_PATTERN =
            Pattern.compile("^[A-Za-z0-9_-]{8,80}\\.[A-Za-z0-9]{1,10}$");

    /** 预览接口路径前缀，与返回给前端的 URL 保持一致 */
    private static final String PREVIEW_PATH = "/api/sys-api/images/preview/";

    @Autowired
    private MinioStorageService minioStorageService;

    /**
     * 上传图片到 MinIO 私有桶。
     * 返回 url 为相对路径（本服务预览接口），前端组件会自动拼接 baseApi 后用于展示。
     */
    @RequestMapping("/api/sys-api/images/upload")
    public AjaxResult uploadImage(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return AjaxResult.error(400, "请选择图片");
        }

        String originalFilename = file.getOriginalFilename();
        if (!StringUtils.hasText(originalFilename) || !originalFilename.contains(".")) {
            return AjaxResult.error(400, "文件名无效");
        }

        String ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        String contentType = MIME_BY_EXT.get(ext);
        if (contentType == null) {
            return AjaxResult.error(400, "不支持的图片格式，仅支持 gif/jpg/jpeg/png");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            return AjaxResult.error(400, "图片大小不能超过 10MB");
        }

        // 校验文件头魔数，防止「改后缀伪装成图片」的上传
        if (!isRealImage(file, ext)) {
            return AjaxResult.error(400, "文件内容不是有效的图片");
        }

        // 对象名完全由服务端生成，不使用原始文件名，避免特殊字符/路径注入
        String objectName = "img_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"))
                + "_" + UUID.randomUUID().toString().replace("-", "") + "." + ext;

        minioStorageService.upload(file, objectName, contentType);

        AjaxResult ajax = AjaxResult.success();
        ajax.put("url", PREVIEW_PATH + objectName);
        ajax.put("fileName", originalFilename);
        ajax.put("newFileName", objectName);
        ajax.put("originalFilename", originalFilename);
        return ajax;
    }

    /**
     * 图片预览：从 MinIO 私有桶读取并中转输出。
     *
     * <p>该接口匿名可访问（已在 SecurityConfig 中 permitAll），因为 {@code <img>} 标签
     * 不会携带 Authorization 请求头；但对象名经过严格白名单校验，只能读取本服务生成的图片对象。</p>
     */
    @GetMapping("/api/sys-api/images/preview/{objectName}")
    public ResponseEntity<byte[]> preview(@PathVariable String objectName) {
        if (!StringUtils.hasText(objectName) || !OBJECT_NAME_PATTERN.matcher(objectName).matches()) {
            return ResponseEntity.badRequest().build();
        }

        String ext = objectName.substring(objectName.lastIndexOf(".") + 1).toLowerCase();
        String contentType = MIME_BY_EXT.getOrDefault(ext, MediaType.APPLICATION_OCTET_STREAM_VALUE);

        try (InputStream inputStream = minioStorageService.getObject(objectName)) {
            byte[] bytes = inputStream.readAllBytes();
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    // inline：浏览器按图片渲染而不是下载
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline")
                    .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                    .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 通过文件头魔数判断文件内容是否真的是对应格式的图片。
     */
    private boolean isRealImage(MultipartFile file, String ext) {
        byte[] head = new byte[12];
        try (InputStream inputStream = file.getInputStream()) {
            int len = inputStream.read(head);
            if (len < 3) {
                return false;
            }
            if ("png".equals(ext)) {
                return len >= 8 && (head[0] & 0xFF) == 0x89 && head[1] == 'P' && head[2] == 'N' && head[3] == 'G';
            }
            if ("gif".equals(ext)) {
                return len >= 6 && (startsWith(head, "GIF87a") || startsWith(head, "GIF89a"));
            }
            if ("jpg".equals(ext) || "jpeg".equals(ext)) {
                return (head[0] & 0xFF) == 0xFF && (head[1] & 0xFF) == 0xD8 && (head[2] & 0xFF) == 0xFF;
            }
            return false;
        } catch (IOException e) {
            return false;
        }
    }

    private boolean startsWith(byte[] head, String prefix) {
        byte[] p = prefix.getBytes(StandardCharsets.US_ASCII);
        if (head.length < p.length) {
            return false;
        }
        for (int i = 0; i < p.length; i++) {
            if (head[i] != p[i]) {
                return false;
            }
        }
        return true;
    }
}
