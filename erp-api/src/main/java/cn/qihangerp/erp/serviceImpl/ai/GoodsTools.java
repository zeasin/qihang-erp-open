package cn.qihangerp.erp.serviceImpl.ai;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.model.entity.OGoods;
import cn.qihangerp.model.entity.OGoodsSku;
import cn.qihangerp.model.query.GoodsQuery;
import cn.qihangerp.service.OGoodsService;
import cn.qihangerp.service.OGoodsSkuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class GoodsTools {

    private final OGoodsService goodsService;
    private final OGoodsSkuService skuService;

    @Tool(description = "根据商品名称关键词搜索ERP商品库中的商品，返回商品名称、编号、零售价、SKU数量等信息")
    public String searchGoods(
            @ToolParam(description = "商品名称搜索关键词") String keyword) {
        log.info("======Tool查询商品:{}",keyword);
        GoodsQuery query = new GoodsQuery();
        query.setName(keyword);
        PageResult<OGoods> result = goodsService.queryPageList(query, new PageQuery());

        List<OGoods> list = result.getRecords();
        if (list == null || list.isEmpty()) {
            return "未找到匹配的商品";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共找到 ").append(result.getTotal()).append(" 个商品：\n");
        int limit = Math.min(list.size(), 10);
        for (int i = 0; i < limit; i++) {
            OGoods g = list.get(i);
            sb.append(i + 1).append(". ").append(g.getName() != null ? g.getName() : "");
            if (g.getGoodsNum() != null) sb.append(" [编号:").append(g.getGoodsNum()).append("]");
            if (g.getRetailPrice() != null) sb.append(" 零售价:").append(g.getRetailPrice().stripTrailingZeros().toPlainString()).append("元");
            if (g.getSkuList() != null && !g.getSkuList().isEmpty()) {
                sb.append(" SKU:").append(g.getSkuList().size()).append("个");
            }
            sb.append("\n");
        }
        if (result.getTotal() > 10) {
            sb.append("... 还有 ").append(result.getTotal() - 10).append(" 个结果未显示");
        }
        return sb.toString();
    }

    @Tool(description = "根据SKU编码、SKU名称或商品名称搜索ERP商品库中的SKU信息，返回SKU编码、名称、价格、规格等详细信息")
    public String searchSku(
            @ToolParam(description = "搜索关键词，可以是SKU编码、SKU名称或商品名称") String keyword) {
        List<OGoodsSku> list = skuService.searchGoodsSpec(keyword);

        if (list == null || list.isEmpty()) {
            return "未找到匹配的SKU";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("共找到 ").append(list.size()).append(" 个SKU：\n");
        for (int i = 0; i < list.size(); i++) {
            OGoodsSku sku = list.get(i);
            sb.append(i + 1).append(". ").append(sku.getGoodsName() != null ? sku.getGoodsName() : "");
            sb.append(" > ").append(sku.getSkuName() != null ? sku.getSkuName() : "");
            sb.append(" [编码:").append(sku.getSkuCode() != null ? sku.getSkuCode() : "").append("]");
            if (sku.getRetailPrice() != null) sb.append(" 零售价:").append(sku.getRetailPrice().stripTrailingZeros().toPlainString()).append("元");
            if (sku.getColorValue() != null) sb.append(" 颜色:").append(sku.getColorValue());
            if (sku.getSizeValue() != null) sb.append(" 尺码:").append(sku.getSizeValue());
            if (sku.getStyleValue() != null) sb.append(" 款式:").append(sku.getStyleValue());
            sb.append("\n");
        }
        return sb.toString();
    }
}
