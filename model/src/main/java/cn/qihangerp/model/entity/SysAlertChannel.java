package cn.qihangerp.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_alert_channel")
public class SysAlertChannel {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String channelType;
    private String channelName;
    private String webhookUrl;
    private String secret;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
