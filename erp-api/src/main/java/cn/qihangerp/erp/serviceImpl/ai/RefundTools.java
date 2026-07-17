package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.service.ShopRefundService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class RefundTools {

    private final ShopRefundService refundService;

    @Tool(description = "查询退款记录列表，可按天数、退款原因、商品名筛选，返回每条记录的商品名、退款原因、退款金额(分)、申请时间、售后状态")
    public String getRefundList(
            @ToolParam(description = "查询最近多少天的退款，默认90天") Integer days,
            @ToolParam(description = "按退款原因筛选。不传则查全部") String reason,
            @ToolParam(description = "按商品名称筛选。不传则查全部") String goodsName,
            @ToolParam(description = "返回的最大记录数，默认200条") Integer limit) {
        if (days == null || days <= 0) days = 90;
        if (limit == null || limit <= 0) limit = 200;

        LambdaQueryWrapper<ShopRefund> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ShopRefund::getCreateOn, LocalDateTime.now().minusDays(days));
        if (reason != null && !reason.isBlank()) {
            wrapper.like(ShopRefund::getReason, reason);
        }
        if (goodsName != null && !goodsName.isBlank()) {
            wrapper.like(ShopRefund::getGoodsName, goodsName);
        }
        wrapper.orderByDesc(ShopRefund::getCreateOn);
        wrapper.last("LIMIT " + limit);
        List<ShopRefund> list = refundService.list(wrapper);

        if (list.isEmpty()) {
            return "近" + days + "天无匹配的退款记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条退款记录（近").append(days).append("天）：\n");
        sb.append("| 商品名 | 退款原因 | 退款金额(分) | 申请时间 | 售后状态 |\n");
        sb.append("|--------|---------|-------------|---------|---------|\n");
        for (ShopRefund r : list) {
            String date = r.getCreateOn() != null
                    ? r.getCreateOn().format(DateTimeFormatter.ofPattern("MM-dd"))
                    : "-";
            String statusText = switch (r.getStatus() != null ? r.getStatus() : -1) {
                case 0 -> "售后申请";
                case 1 -> "已关闭";
                case 2 -> "处理中";
                case 3 -> "退款中";
                case 4 -> "售后成功";
                default -> "未知";
            };
            sb.append("| ").append(r.getGoodsName() != null ? r.getGoodsName() : "-")
                    .append(" | ").append(r.getReason() != null ? r.getReason() : "-")
                    .append(" | ").append(r.getRefundAmount() != null ? r.getRefundAmount() : 0)
                    .append(" | ").append(date)
                    .append(" | ").append(statusText)
                    .append(" |\n");
        }

        return sb.toString();
    }
}
