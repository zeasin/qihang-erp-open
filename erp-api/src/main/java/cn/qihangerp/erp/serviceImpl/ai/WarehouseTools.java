package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ErpWarehouse;
import cn.qihangerp.service.ErpWarehouseService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class WarehouseTools {

    private final ErpWarehouseService warehouseService;

    @Tool(description = "查询仓库列表，返回每条记录的仓库名称、类型、状态、地址信息")
    public String getWarehouseList() {
        LambdaQueryWrapper<ErpWarehouse> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErpWarehouse::getStatus, "ENABLE");
        List<ErpWarehouse> list = warehouseService.list(wrapper);

        if (list.isEmpty()) {
            return "无启用的仓库记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 个仓库：\n");
        sb.append("| 仓库名称 | 类型 | 地址 | 联系人 | 联系电话 |\n");
        sb.append("|----------|------|------|--------|--------|\n");
        for (ErpWarehouse w : list) {
            String typeText = w.getType() != null && w.getType() == 2 ? "云仓" : "本地仓";
            String addr = w.getProvince() != null ? w.getProvince() + w.getCity() + w.getCounty() : "-";
            sb.append("| ").append(w.getWarehouseName() != null ? w.getWarehouseName() : "-")
                    .append(" | ").append(typeText)
                    .append(" | ").append(addr)
                    .append(" | ").append(w.getContacts() != null ? w.getContacts() : "-")
                    .append(" | ").append(w.getPhone() != null ? w.getPhone() : "-")
                    .append(" |\n");
        }

        return sb.toString();
    }
}
