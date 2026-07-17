package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ErpPurchaseOrder;
import cn.qihangerp.service.ErpPurchaseOrderService;
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
public class PurchaseTools {

    private final ErpPurchaseOrderService purchaseOrderService;

    @Tool(description = "查询采购单列表，可按天数和状态筛选，返回每条记录的采购单号、供应商、金额、状态、创建时间")
    public String getPurchaseOrderList(
            @ToolParam(description = "查询最近多少天的采购单，默认90天") Integer days,
            @ToolParam(description = "采购单状态：0待审核 1已审核 101供应商已确认 102供应商已发货 2已收货 3已入库。不传则查全部") Integer status,
            @ToolParam(description = "返回的最大记录数，默认100条") Integer limit) {
        if (days == null || days <= 0) days = 90;
        if (limit == null || limit <= 0) limit = 100;

        LambdaQueryWrapper<ErpPurchaseOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ErpPurchaseOrder::getCreateTime, LocalDateTime.now().minusDays(days));
        if (status != null) {
            wrapper.eq(ErpPurchaseOrder::getStatus, status);
        }
        wrapper.orderByDesc(ErpPurchaseOrder::getCreateTime);
        wrapper.last("LIMIT " + limit);
        List<ErpPurchaseOrder> list = purchaseOrderService.list(wrapper);

        if (list.isEmpty()) {
            return "近" + days + "天无匹配的采购单记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条采购单记录（近").append(days).append("天）：\n");
        sb.append("| 采购单号 | 供应商 | 金额(元) | 状态 | 创建时间 |\n");
        sb.append("|----------|--------|---------|------|---------|\n");
        for (ErpPurchaseOrder o : list) {
            String statusText = switch (o.getStatus() != null ? o.getStatus() : -1) {
                case 0 -> "待审核";
                case 1 -> "已审核";
                case 101 -> "供应商已确认";
                case 102 -> "供应商已发货";
                case 2 -> "已收货";
                case 3 -> "已入库";
                default -> "未知";
            };
            String date = o.getCreateTime() != null
                    ? o.getCreateTime().format(DateTimeFormatter.ofPattern("MM-dd HH:mm"))
                    : "-";
            sb.append("| ").append(o.getOrderNum() != null ? o.getOrderNum() : "-")
                    .append(" | ").append(o.getWarehouseName() != null ? o.getWarehouseName() : "-")
                    .append(" | ").append(o.getOrderAmount() != null ? o.getOrderAmount() : 0)
                    .append(" | ").append(statusText)
                    .append(" | ").append(date)
                    .append(" |\n");
        }

        return sb.toString();
    }
}
