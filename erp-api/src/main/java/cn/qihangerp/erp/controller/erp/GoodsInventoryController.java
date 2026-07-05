package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.entity.OGoodsInventory;
import cn.qihangerp.model.entity.OGoodsInventoryBatch;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.OGoodsInventoryBatchService;
import cn.qihangerp.service.OGoodsInventoryService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 主系统商品库存 Controller
 * 使用 o_goods_inventory / o_goods_inventory_batch 两张表
 * 区别于多仓库子系统的 ErpWarehouseGoodsStockController
 */
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/goodsInventory")
public class GoodsInventoryController extends BaseController {

    private final OGoodsInventoryService goodsInventoryService;
    private final OGoodsInventoryBatchService inventoryBatchService;

    /**
     * 分页查询主系统库存列表
     */
    @GetMapping("/list")
    public TableDataInfo list(OGoodsInventory bo, PageQuery pageQuery) {
        PageResult<OGoodsInventory> pageResult = goodsInventoryService.queryPageList(bo, pageQuery);
        return getDataTable(pageResult);
    }

    /**
     * 查询库存批次明细
     *
     * @param id 库存记录ID (o_goods_inventory.id)
     */
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id) {
        OGoodsInventory goodsInventory = goodsInventoryService.getById(id);
        if (goodsInventory != null) {
            List<OGoodsInventoryBatch> list = inventoryBatchService.listByInventoryId(id);
            return AjaxResult.success(list);
        }
        return success();
    }
}