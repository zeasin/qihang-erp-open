package cn.qihangerp.service;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.model.entity.OGoodsInventory;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 主系统商品库存 Service 接口
 *
 * @author qihang
 */
public interface OGoodsInventoryService extends IService<OGoodsInventory> {

    /**
     * 分页查询库存列表
     */
    PageResult<OGoodsInventory> queryPageList(OGoodsInventory bo, PageQuery pageQuery);

    /**
     * 扣减库存（出库时调用）
     *
     * @param inventoryId 库存记录ID
     * @param quantity    扣减数量
     * @return 是否成功
     */
    boolean deductStock(Long inventoryId, Integer quantity);

    /**
     * 增加库存（入库时调用）
     *
     * @param inventoryId 库存记录ID
     * @param quantity    增加数量
     * @return 是否成功
     */
    boolean addStock(Long inventoryId, Integer quantity);

    /**
     * 锁定/解锁库存
     *
     * @param inventoryId 库存记录ID
     * @param quantity    锁定数量（正数锁定，负数解锁）
     * @return 是否成功
     */
    boolean lockStock(Long inventoryId, Integer quantity);
}