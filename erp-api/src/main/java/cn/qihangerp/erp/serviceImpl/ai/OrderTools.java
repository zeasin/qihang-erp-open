package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ShopOrder;
import cn.qihangerp.service.ShopOrderService;
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
public class OrderTools {

    private final ShopOrderService orderService;

    @Tool(description = "查询店铺订单列表，可按天数和订单状态筛选，返回每条记录的订单号、订单金额(分)、支付金额(分)、收件人、收货地址、订单状态、发货状态、下单时间")
    public String getOrderList(
            @ToolParam(description = "查询最近多少天的订单，默认30天") Integer days,
            @ToolParam(description = "订单状态：0新订单 1待发货 2已发货 3已完成 11已取消 12退款中 13已关闭 21待付款。不传则查全部") Integer orderStatus,
            @ToolParam(description = "返回的最大记录数，默认100条") Integer limit) {
        if (days == null || days <= 0) days = 30;
        if (limit == null || limit <= 0) limit = 100;

        LambdaQueryWrapper<ShopOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ShopOrder::getCreateOn, LocalDateTime.now().minusDays(days));
        if (orderStatus != null) {
            wrapper.eq(ShopOrder::getOrderStatus, orderStatus);
        }
        wrapper.orderByDesc(ShopOrder::getCreateOn);
        wrapper.last("LIMIT " + limit);
        List<ShopOrder> list = orderService.list(wrapper);

        if (list.isEmpty()) {
            return "近" + days + "天无匹配的订单记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条订单记录（近").append(days).append("天）：\n");
        sb.append("| 订单号 | 订单金额(分) | 支付金额(分) | 收件人 | 收货地址 | 订单状态 | 发货状态 | 下单时间 |\n");
        sb.append("|--------|-------------|-------------|--------|---------|---------|---------|---------|\n");
        for (ShopOrder o : list) {
            String statusText = switch (o.getOrderStatus() != null ? o.getOrderStatus() : -1) {
                case 0 -> "新订单";
                case 1 -> "待发货";
                case 2 -> "已发货";
                case 3 -> "已完成";
                case 11 -> "已取消";
                case 12 -> "退款中";
                case 13 -> "已关闭";
                case 21 -> "待付款";
                case 22 -> "锁定";
                case 29 -> "已删除";
                case 101 -> "部分发货";
                default -> "未知";
            };
            String shipText = switch (o.getErpShipStatus() != null ? o.getErpShipStatus() : -1) {
                case 0 -> "待发货";
                case 1 -> "部分发货";
                case 2 -> "已发货";
                default -> "未知";
            };
            String address = (o.getProvince() != null ? o.getProvince() : "")
                    + (o.getCity() != null ? o.getCity() : "")
                    + (o.getCounty() != null ? o.getCounty() : "")
                    + (o.getAddress() != null ? o.getAddress() : "");
            String date = o.getCreateOn() != null
                    ? o.getCreateOn().format(DateTimeFormatter.ofPattern("MM-dd HH:mm"))
                    : "-";
            sb.append("| ").append(o.getOrderId() != null ? o.getOrderId() : "-")
                    .append(" | ").append(o.getOrderAmount() != null ? o.getOrderAmount() : 0)
                    .append(" | ").append(o.getPaymentAmount() != null ? o.getPaymentAmount() : 0)
                    .append(" | ").append(o.getReceiverName() != null ? o.getReceiverName() : "-")
                    .append(" | ").append(address.isBlank() ? "-" : address)
                    .append(" | ").append(statusText)
                    .append(" | ").append(shipText)
                    .append(" | ").append(date)
                    .append(" |\n");
        }

        return sb.toString();
    }
}
