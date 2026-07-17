package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.model.vo.SalesDailyVo;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.OShopService;
import cn.qihangerp.service.ShopRefundService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataTools {

    private final OOrderService orderService;
    private final OShopService shopService;
    private final ShopRefundService refundService;

    @Tool(description = "获取最近N天的销售统计，返回每日销售额、订单数、待发货数")
    public String getSalesSummary(
            @ToolParam(description = "要查询的天数，默认7天") Integer days) {
        if (days == null || days <= 0) days = 7;
        List<SalesDailyVo> list = orderService.salesDaily();
        if (list == null || list.isEmpty()) {
            return "暂无销售数据";
        }
        int limit = Math.min(list.size(), days);
        StringBuilder sb = new StringBuilder();
        sb.append("近").append(limit).append("日销售数据：\n");
        double totalAmount = 0;
        int totalOrders = 0;
        for (int i = 0; i < limit; i++) {
            SalesDailyVo d = list.get(i);
            sb.append("  ").append(d.getDate())
                    .append(" 销售额:").append(d.getAmount() != null ? d.getAmount() : 0)
                    .append("元 订单数:").append(d.getCount() != null ? d.getCount() : 0)
                    .append(" 待发货:").append(d.getWaitSend() != null ? d.getWaitSend() : 0)
                    .append("\n");
            totalAmount += d.getAmount() != null ? d.getAmount() : 0;
            totalOrders += d.getCount() != null ? d.getCount() : 0;
        }
        sb.append("\n合计：销售额").append(totalAmount).append("元，总订单").append(totalOrders).append("单");
        return sb.toString();
    }

    @Tool(description = "获取待发货订单总数统计")
    public String getWaitShipReport() {
        Integer count = orderService.getWaitShipOrderAllCount(0L);
        if (count == null || count == 0) {
            return "当前没有待发货订单";
        }
        return "待发货订单共 " + count + " 单，建议尽快安排发货";
    }

    @Tool(description = "获取今日销售数据，包括销售额、订单数、待发货数")
    public String getTodaySales() {
        SalesDailyVo today = orderService.getTodaySalesDaily(0L);
        if (today == null) {
            return "今日暂无销售数据";
        }
        return "今日数据：销售额" + (today.getAmount() != null ? today.getAmount() : 0)
                + "元，订单" + (today.getCount() != null ? today.getCount() : 0)
                + "单，待发货" + (today.getWaitSend() != null ? today.getWaitSend() : 0) + "单";
    }

    @Tool(description = "获取所有店铺列表及平台类型，返回店铺名称、所属平台")
    public String getShopList() {
        var shops = shopService.list();
        if (shops == null || shops.isEmpty()) {
            return "暂无店铺数据";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(shops.size()).append(" 个店铺：\n");
        for (var shop : shops) {
            sb.append("  - ").append(shop.getName() != null ? shop.getName() : "")
                    .append(" [平台类型:").append(shop.getType() != null ? shop.getType() : "").append("]\n");
        }
        return sb.toString();
    }

    @Tool(description = "获取退款/售后数据统计，返回退款总数、待处理退款数")
    public String getRefundSummary() {
        long total = refundService.count();
        LambdaQueryWrapper<ShopRefund> pending = new LambdaQueryWrapper<>();
        pending.eq(ShopRefund::getStatus, 0);
        long pendingCount = refundService.count(pending);
        return "退款总计" + total + "条，待处理" + pendingCount + "条";
    }

    @Tool(description = "获取退款率统计，返回近30天退款单数和占比")
    public String getRefundRate() {
        LambdaQueryWrapper<ShopRefund> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(ShopRefund::getCreateOn, LocalDateTime.now().minusDays(30));
        long monthRefunds = refundService.count(wrapper);
        return "近30天退款" + monthRefunds + "单";
    }
}
