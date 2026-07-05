package cn.qihangerp.model.request;

import lombok.Data;

@Data
public class RefundPullRequest {
    private Long shopId;//店铺Id
    private String orderId;
    private String refundId;
    private String afterId;// 平台售后单号（与 refundId 同义，兼容前端字段）
    private String createTime;
    private String updateTime;
}
