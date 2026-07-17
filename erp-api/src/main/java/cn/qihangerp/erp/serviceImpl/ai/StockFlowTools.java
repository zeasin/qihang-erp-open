package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ErpStockIn;
import cn.qihangerp.model.entity.ErpStockOut;
import cn.qihangerp.service.ErpStockInService;
import cn.qihangerp.service.ErpStockOutService;
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
public class StockFlowTools {

    private final ErpStockInService stockInService;
    private final ErpStockOutService stockOutService;

    @Tool(description = "查询入库单列表，可按天数和入库类型筛选，返回每条记录的入库单号、类型、来源单号、状态、入库时间")
    public String getStockInList(
            @ToolParam(description = "查询最近多少天的入库单，默认30天") Integer days,
            @ToolParam(description = "入库类型：1采购入库 2退货入库。不传则查全部") Integer stockInType,
            @ToolParam(description = "返回的最大记录数，默认100条") Integer limit) {
        if (days == null || days <= 0) days = 30;
        if (limit == null || limit <= 0) limit = 100;

        LambdaQueryWrapper<ErpStockIn> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ErpStockIn::getCreateTime, LocalDateTime.now().minusDays(days));
        if (stockInType != null) {
            wrapper.eq(ErpStockIn::getStockInType, stockInType);
        }
        wrapper.orderByDesc(ErpStockIn::getCreateTime);
        wrapper.last("LIMIT " + limit);
        List<ErpStockIn> list = stockInService.list(wrapper);

        if (list.isEmpty()) {
            return "近" + days + "天无匹配的入库单记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条入库单记录（近").append(days).append("天）：\n");
        sb.append("| 入库单号 | 入库类型 | 来源单号 | 仓库 | 状态 | 入库人 | 入库时间 |\n");
        sb.append("|----------|---------|---------|------|------|--------|---------|\n");
        for (ErpStockIn s : list) {
            String typeText = switch (s.getStockInType() != null ? s.getStockInType() : 0) {
                case 1 -> "采购入库";
                case 2 -> "退货入库";
                default -> "其他";
            };
            String statusText = switch (s.getStatus() != null ? s.getStatus() : 0) {
                case 0 -> "待入库";
                case 1 -> "部分入库";
                case 2 -> "全部入库";
                default -> "未知";
            };
            String date = s.getStockInTime() != null
                    ? s.getStockInTime().format(DateTimeFormatter.ofPattern("MM-dd HH:mm"))
                    : "-";
            sb.append("| ").append(s.getStockInNum() != null ? s.getStockInNum() : "-")
                    .append(" | ").append(typeText)
                    .append(" | ").append(s.getSourceNo() != null ? s.getSourceNo() : "-")
                    .append(" | ").append(s.getWarehouseName() != null ? s.getWarehouseName() : "-")
                    .append(" | ").append(statusText)
                    .append(" | ").append(s.getStockInOperator() != null ? s.getStockInOperator() : "-")
                    .append(" | ").append(date)
                    .append(" |\n");
        }

        return sb.toString();
    }

    @Tool(description = "查询出库单列表，可按天数和类型筛选，返回每条记录的出库单号、类型、来源单号、状态、出库时间")
    public String getStockOutList(
            @ToolParam(description = "查询最近多少天的出库单，默认30天") Integer days,
            @ToolParam(description = "出库类型：1订单发货出库 2采购退货出库 3盘点出库 4报损出库。不传则查全部") Integer type,
            @ToolParam(description = "返回的最大记录数，默认100条") Integer limit) {
        if (days == null || days <= 0) days = 30;
        if (limit == null || limit <= 0) limit = 100;

        LambdaQueryWrapper<ErpStockOut> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ErpStockOut::getCreateTime, LocalDateTime.now().minusDays(days));
        if (type != null) {
            wrapper.eq(ErpStockOut::getType, type);
        }
        wrapper.orderByDesc(ErpStockOut::getCreateTime);
        wrapper.last("LIMIT " + limit);
        List<ErpStockOut> list = stockOutService.list(wrapper);

        if (list.isEmpty()) {
            return "近" + days + "天无匹配的出库单记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条出库单记录（近").append(days).append("天）：\n");
        sb.append("| 出库单号 | 出库类型 | 来源单号 | 仓库 | 状态 | 出库人 | 出库时间 |\n");
        sb.append("|----------|---------|---------|------|------|--------|---------|\n");
        for (ErpStockOut s : list) {
            String typeText = switch (s.getType() != null ? s.getType() : 0) {
                case 1 -> "订单发货";
                case 2 -> "采购退货";
                case 3 -> "盘点出库";
                case 4 -> "报损出库";
                default -> "其他";
            };
            String statusText = switch (s.getStatus() != null ? s.getStatus() : 0) {
                case 0 -> "待出库";
                case 1 -> "部分出库";
                case 2 -> "全部出库";
                default -> "未知";
            };
            String date = s.getOutTime() != null
                    ? s.getOutTime().format(DateTimeFormatter.ofPattern("MM-dd HH:mm"))
                    : "-";
            sb.append("| ").append(s.getOutNum() != null ? s.getOutNum() : "-")
                    .append(" | ").append(typeText)
                    .append(" | ").append(s.getSourceNum() != null ? s.getSourceNum() : "-")
                    .append(" | ").append(s.getWarehouseName() != null ? s.getWarehouseName() : "-")
                    .append(" | ").append(statusText)
                    .append(" | ").append(s.getOperatorName() != null ? s.getOperatorName() : "-")
                    .append(" | ").append(date)
                    .append(" |\n");
        }

        return sb.toString();
    }
}
