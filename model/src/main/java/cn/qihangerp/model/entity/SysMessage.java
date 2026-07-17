package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_message")
public class SysMessage {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String type;
    private String level;
    private String title;
    private String content;
    private String link;
    private String source;
    private Integer isRead;
    private LocalDateTime createdTime;
    private LocalDateTime readTime;
}
