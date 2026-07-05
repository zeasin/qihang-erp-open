package cn.qihangerp.service.impl;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.mapper.OGoodsInventoryMapper;
import cn.qihangerp.model.entity.OGoodsInventory;
import cn.qihangerp.service.OGoodsInventoryService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 主系统商品库存 Service 实现
 *
 * @author qihang
 */
@AllArgsConstructor
@Service
public class OGoodsInventoryServiceImpl
        extends ServiceImpl<OGoodsInventoryMapper, OGoodsInventory>
        implements OGoodsInventoryService {

    @Override
    public PageResult<OGoodsInventory> queryPageList(OGoodsInventory bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OGoodsInventory> qw = new LambdaQueryWrapper<OGoodsInventory>()
                .eq(bo.getIsDelete() != null, OGoodsInventory::getIsDelete, bo.getIsDelete())
                .eq(bo.getWarehouseId() != null, OGoodsInventory::getWarehouseId, bo.getWarehouseId())
                .eq(bo.getMerchantId() != null, OGoodsInventory::getMerchantId, bo.getMerchantId())
                .eq(bo.getSkuId() != null, OGoodsInventory::getSkuId, bo.getSkuId())
                .eq(bo.getGoodsId() != null, OGoodsInventory::getGoodsId, bo.getGoodsId())
                .eq(OGoodsInventory::getSkuCode, bo.getSkuCode())
                .like(bo.getGoodsName() != null, OGoodsInventory::getGoodsName, bo.getGoodsName());
        // 默认只查未删除的
        if (bo.getIsDelete() == null) {
            qw.eq(OGoodsInventory::getIsDelete, 0);
        }
        IPage<OGoodsInventory> page = this.baseMapper.selectPage(pageQuery.build(), qw);
        return PageResult.build(page);
    }

    @Override
    public boolean deductStock(Long inventoryId, Integer quantity) {
        OGoodsInventory inv = this.getById(inventoryId);
        if (inv == null || inv.getQuantity() < quantity) return false;

        OGoodsInventory update = new OGoodsInventory();
        update.setId(inventoryId);
        update.setQuantity(inv.getQuantity() - quantity);
        update.setAvailableQuantity(inv.getAvailableQuantity() - quantity);
        return this.updateById(update);
    }

    @Override
    public boolean addStock(Long inventoryId, Integer quantity) {
        OGoodsInventory inv = this.getById(inventoryId);
        if (inv == null) return false;

        OGoodsInventory update = new OGoodsInventory();
        update.setId(inventoryId);
        update.setQuantity(inv.getQuantity() + quantity);
        update.setAvailableQuantity(inv.getAvailableQuantity() + quantity);
        return this.updateById(update);
    }

    @Override
    public boolean lockStock(Long inventoryId, Integer quantity) {
        OGoodsInventory inv = this.getById(inventoryId);
        if (inv == null) return false;
        // 如果是负数（解锁），不能解锁超过已锁定的数量
        if (quantity < 0 && inv.getLockedQuantity() < -quantity) return false;

        OGoodsInventory update = new OGoodsInventory();
        update.setId(inventoryId);
        update.setLockedQuantity(inv.getLockedQuantity() + quantity);
        update.setAvailableQuantity(inv.getAvailableQuantity() - quantity);
        return this.updateById(update);
    }
}