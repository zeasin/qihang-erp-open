package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.OGoodsInventory;
import cn.qihangerp.service.OGoodsInventoryService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class InventoryTools {

    private final OGoodsInventoryService inventoryService;

    @Tool(description = "查询SKU库存列表，可按可用库存范围筛选，返回每条记录的SKU名称、编码、可用库存、仓库ID")
    public String getInventoryList(
            @ToolParam(description = "查询可用库存小于等于此值的SKU。不传则查全部") Integer availableLte,
            @ToolParam(description = "返回的最大记录数，默认100条") Integer limit) {
        if (limit == null || limit <= 0) limit = 100;

        LambdaQueryWrapper<OGoodsInventory> wrapper = new LambdaQueryWrapper<>();
        if (availableLte != null) {
            wrapper.le(OGoodsInventory::getAvailableQuantity, availableLte);
        }
        wrapper.orderByAsc(OGoodsInventory::getAvailableQuantity);
        wrapper.last("LIMIT " + limit);
        List<OGoodsInventory> list = inventoryService.list(wrapper);

        if (list.isEmpty()) {
            return "暂无匹配的库存记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条库存记录：\n");
        sb.append("| SKU名称 | 编码 | 可用库存 | 仓库ID |\n");
        sb.append("|---------|------|---------|-------|\n");
        for (OGoodsInventory inv : list) {
            sb.append("| ").append(inv.getSkuName() != null ? inv.getSkuName() : "-")
                    .append(" | ").append(inv.getSkuCode() != null ? inv.getSkuCode() : "-")
                    .append(" | ").append(inv.getAvailableQuantity())
                    .append(" | ").append(inv.getWarehouseId() != null ? inv.getWarehouseId() : "-")
                    .append(" |\n");
        }

        return sb.toString();
    }
}
