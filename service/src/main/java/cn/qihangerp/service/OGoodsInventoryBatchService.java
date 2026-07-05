package cn.qihangerp.service;

import cn.qihangerp.model.entity.OGoodsInventoryBatch;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 主系统商品库存批次 Service 接口
 *
 * @author qihang
 */
public interface OGoodsInventoryBatchService extends IService<OGoodsInventoryBatch> {

    /**
     * 根据库存记录ID查询批次列表
     */
    java.util.List<OGoodsInventoryBatch> listByInventoryId(Long inventoryId);

    /**
     * 扣减批次库存
     *
     * @param batchId  批次ID
     * @param quantity 扣减数量
     * @return 是否成功
     */
    boolean deductBatchStock(Long batchId, Integer quantity);
}