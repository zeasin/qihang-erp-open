package cn.qihangerp.erp.controller.sys;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.entity.SysConfig;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.SysConfigService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.metadata.OrderItem;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.Map;

/**
 * 系统参数配置接口。
 *
 * <p>后台「系统管理 - 参数配置」页面的增删改查入口。MinIO 的 4 个配置项
 * （minio.endpoint / accessKey / secretKey / bucket）也在该页面维护。</p>
 *
 * @author qilip
 */
@AllArgsConstructor
@RestController
@RequestMapping("/api/sys-api/system/config")
public class SysConfigController extends BaseController {

    private final SysConfigService configService;

    /**
     * 列表查询参数。params 用于接收前端 addDateRange 生成的 params[beginTime] / params[endTime]。
     */
    @Data
    public static class ConfigQuery {
        private Integer pageNum;
        private Integer pageSize;
        private String configName;
        private String configKey;
        private String configType;
        private Map<String, Object> params;
    }

    /**
     * 分页查询参数配置列表
     */
    @PreAuthorize("@ss.hasPermi('system:config:list')")
    @GetMapping("/list")
    public TableDataInfo list(ConfigQuery query) {
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(query.getConfigName()), SysConfig::getConfigName, query.getConfigName())
                .like(StringUtils.hasText(query.getConfigKey()), SysConfig::getConfigKey, query.getConfigKey())
                .eq(StringUtils.hasText(query.getConfigType()), SysConfig::getConfigType, query.getConfigType());

        LocalDateTime begin = parseDay(query, "beginTime", true);
        LocalDateTime end = parseDay(query, "endTime", false);
        wrapper.ge(begin != null, SysConfig::getCreateTime, begin)
                .le(end != null, SysConfig::getCreateTime, end);

        int pageNum = (query.getPageNum() == null || query.getPageNum() < 1) ? 1 : query.getPageNum();
        int pageSize = (query.getPageSize() == null || query.getPageSize() < 1) ? 10 : query.getPageSize();
        // 注意：不能用 PageQuery.build()，它默认按 "id" 排序，而本表主键是 config_id
        Page<SysConfig> page = new Page<>(pageNum, pageSize);
        page.addOrder(OrderItem.desc("config_id"));
        IPage<SysConfig> result = configService.page(page, wrapper);
        return getDataTable(PageResult.build(result));
    }

    private LocalDateTime parseDay(ConfigQuery query, String key, boolean startOfDay) {
        Map<String, Object> params = query.getParams();
        if (params == null) {
            return null;
        }
        Object value = params.get(key);
        if (value == null || !StringUtils.hasText(value.toString())) {
            return null;
        }
        try {
            LocalDate date = LocalDate.parse(value.toString().trim());
            return startOfDay ? date.atStartOfDay() : date.atTime(LocalTime.MAX);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    /**
     * 根据主键查询参数配置（后台编辑表单回显用）
     */
    @PreAuthorize("@ss.hasPermi('system:config:query')")
    @GetMapping("/{configId}")
    public AjaxResult getInfo(@PathVariable Integer configId) {
        return success(configService.getById(configId));
    }

    /**
     * 按参数键名查询（保留原接口，供其它业务读取配置）
     */
    @GetMapping(value = "/getConfigValue/{key}")
    public AjaxResult getConfigValue(@PathVariable String key) {
        SysConfig config = getByKey(key);
        return config == null ? AjaxResult.success() : AjaxResult.success(config);
    }

    /**
     * 根据参数键名查询参数值
     */
    @GetMapping(value = "/configKey/{configKey}")
    public AjaxResult getConfigByKey(@PathVariable String configKey) {
        SysConfig config = getByKey(configKey);
        return config == null ? AjaxResult.success() : AjaxResult.success(config);
    }

    private SysConfig getByKey(String key) {
        if (!StringUtils.hasText(key)) {
            return null;
        }
        return configService.getOne(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, key));
    }

    /**
     * 新增参数配置
     */
    @PreAuthorize("@ss.hasPermi('system:config:add')")
    @PostMapping
    public AjaxResult add(@RequestBody SysConfig config) {
        if (!StringUtils.hasText(config.getConfigKey())) {
            return error("参数键名不能为空");
        }
        if (existsKey(config.getConfigKey(), null)) {
            return error("新增参数'" + config.getConfigName() + "'失败，参数键名已存在");
        }
        config.setConfigId(null);
        config.setCreateBy(getUsername());
        config.setCreateTime(LocalDateTime.now());
        return toAjax(configService.save(config));
    }

    /**
     * 修改参数配置
     */
    @PreAuthorize("@ss.hasPermi('system:config:edit')")
    @PutMapping
    public AjaxResult edit(@RequestBody SysConfig config) {
        if (config.getConfigId() == null) {
            return error("参数主键不能为空");
        }
        if (existsKey(config.getConfigKey(), config.getConfigId())) {
            return error("修改参数'" + config.getConfigName() + "'失败，参数键名已存在");
        }
        config.setUpdateBy(getUsername());
        config.setUpdateTime(LocalDateTime.now());
        return toAjax(configService.updateById(config));
    }

    private boolean existsKey(String key, Integer excludeId) {
        if (!StringUtils.hasText(key)) {
            return false;
        }
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<SysConfig>()
                .eq(SysConfig::getConfigKey, key);
        if (excludeId != null) {
            wrapper.ne(SysConfig::getConfigId, excludeId);
        }
        return configService.count(wrapper) > 0;
    }

    /**
     * 批量删除参数配置
     */
    @PreAuthorize("@ss.hasPermi('system:config:remove')")
    @DeleteMapping("/{configIds}")
    public AjaxResult remove(@PathVariable Integer[] configIds) {
        return toAjax(configService.removeByIds(Arrays.asList(configIds)));
    }

    /**
     * 刷新缓存。
     *
     * <p>当前 sys_config 未启用缓存：MinioStorageService 每次调用都实时读库，
     * 在页面改完 MinIO 配置后立即生效。此接口仅为兼容前端按钮保留。</p>
     */
    @PreAuthorize("@ss.hasPermi('system:config:remove')")
    @DeleteMapping("/refreshCache")
    public AjaxResult refreshCache() {
        return success();
    }
}
