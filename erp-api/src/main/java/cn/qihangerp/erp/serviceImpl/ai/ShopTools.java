package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.service.OShopService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class ShopTools {

    private final OShopService shopService;

    @Tool(description = "获取所有店铺列表，返回每条记录的店铺名称、平台类型")
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
}
