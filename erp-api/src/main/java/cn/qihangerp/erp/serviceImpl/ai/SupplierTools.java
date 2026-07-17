package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.model.entity.ErpSupplier;
import cn.qihangerp.service.ErpSupplierService;
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
public class SupplierTools {

    private final ErpSupplierService supplierService;

    @Tool(description = "查询供应商列表，可按名称关键词搜索，返回每条记录的供应商名、联系人、联系电话、地址")
    public String getSupplierList(
            @ToolParam(description = "供应商名称搜索关键词") String keyword,
            @ToolParam(description = "返回的最大记录数，默认50条") Integer limit) {
        if (limit == null || limit <= 0) limit = 50;

        LambdaQueryWrapper<ErpSupplier> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErpSupplier::getIsDelete, 0);
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(ErpSupplier::getName, keyword);
        }
        wrapper.orderByAsc(ErpSupplier::getName);
        wrapper.last("LIMIT " + limit);
        List<ErpSupplier> list = supplierService.list(wrapper);

        if (list.isEmpty()) {
            return "无匹配的供应商记录";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(list.size()).append(" 条供应商记录：\n");
        sb.append("| 供应商名 | 联系人 | 联系电话 | 地址 |\n");
        sb.append("|----------|--------|---------|------|\n");
        for (ErpSupplier s : list) {
            String address = (s.getProvince() != null ? s.getProvince() : "")
                    + (s.getCity() != null ? s.getCity() : "")
                    + (s.getCounty() != null ? s.getCounty() : "")
                    + (s.getAddress() != null ? s.getAddress() : "");
            sb.append("| ").append(s.getName() != null ? s.getName() : "-")
                    .append(" | ").append(s.getLinkMan() != null ? s.getLinkMan() : "-")
                    .append(" | ").append(s.getContact() != null ? s.getContact() : "-")
                    .append(" | ").append(address.isBlank() ? "-" : address)
                    .append(" |\n");
        }

        return sb.toString();
    }
}
