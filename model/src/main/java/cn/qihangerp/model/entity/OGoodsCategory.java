package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 商品分类表
 * @TableName o_goods_category
 */
@Data
@TableName("o_goods_category")
public class OGoodsCategory implements Serializable {
    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 分类编码（长度限制18）
     */
    @NotBlank(message = "分类编码不能为空")
    @Size(max = 18, message = "分类编码长度不能超过18个字符")
    @TableField("number")
    private String number;

    /**
     * 分类名称（长度限制20）
     */
    @NotBlank(message = "分类名称不能为空")
    @Size(max = 20, message = "分类名称长度不能超过20个字符")
    @TableField("name")
    private String name;

    /**
     * 备注（长度限制50）
     */
    @Size(max = 50, message = "备注长度不能超过50个字符")
    @TableField("remark")
    private String remark;

    /**
     * 上级分类id，0=一级分类
     */
    @TableField("parent_id")
    private Long parentId;

    /**
     * 分类路径（保留较长，支持多级分类树）
     */
    @Size(max = 500, message = "分类路径长度不能超过500个字符")
    @TableField("path")
    private String path;

    /**
     * 排序值
     */
    @TableField("sort")
    private Integer sort;

    /**
     * 图片
     */
    @TableField("image")
    private String image;

    /**
     * 0正常  1删除
     */
    @TableField("isdelete")
    private Integer isdelete;

    /**
     * 创建人
     */
    @TableField("create_by")
    private String createBy;

    /**
     * 创建时间
     */
    @TableField("create_time")
    private LocalDateTime createTime;

    /**
     * 更新人
     */
    @TableField("update_by")
    private String updateBy;

    /**
     * 更新时间
     */
    @TableField("update_time")
    private LocalDateTime updateTime;

    /**
     * 商户ID（默认0=总部系统）
     */
    @TableField("merchant_id")
    private Long merchantId;

    private static final long serialVersionUID = 1L;
}
