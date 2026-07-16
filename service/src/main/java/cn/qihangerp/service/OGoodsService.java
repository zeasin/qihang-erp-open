package cn.qihangerp.service;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;

import cn.qihangerp.model.entity.OGoods;
import cn.qihangerp.model.bo.GoodsAddBo;
import cn.qihangerp.model.bo.GoodsSkuAddBo;
import cn.qihangerp.model.bo.GoodsSkuNewAddBo;
import cn.qihangerp.model.query.GoodsQuery;
import cn.qihangerp.model.query.GoodsSkuQuery;
import cn.qihangerp.model.vo.GoodsSpecListVo;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.qihangerp.model.entity.OGoodsSku;


import java.util.List;

/**
* @author TW
* @description 针对表【o_goods(商品库存管理)】的数据库操作Service
* @createDate 2024-03-11 14:24:49
*/
public interface OGoodsService extends IService<OGoods> {
    /**
     * 分页查询所有商品列表
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OGoods> queryPageList(GoodsQuery bo, PageQuery pageQuery);



    /**
     * 商品sku列表
     * @param bo
     * @param pageQuery
     * @return
     */
    PageResult<OGoodsSku> querySkuPageList(GoodsSkuQuery bo, PageQuery pageQuery);

    PageResult<OGoodsSku> querySkuMerchantPageList(Long merchantId,GoodsSkuQuery bo, PageQuery pageQuery);
    PageResult<OGoodsSku> querySkuMerchantShopPageList(Long merchantId,Long shopId,GoodsSkuQuery bo, PageQuery pageQuery);






    List<OGoodsSku> querySkuByIds(List<Long> ids);
    List<OGoodsSku> querySkuByGoodsId(Long goodsId);


    List<GoodsSpecListVo> searchGoodsSpec(String keyword);
    List<GoodsSpecListVo> getVendorGoodsSpecByCode(String skuCode);

    OGoods selectGoodsById(Long id);
    /**
     * 新增商品管理
     *
     * @param goods 商品管理
     * @return 结果
     */
     ResultVo<Long> insertGoods(String userName , GoodsAddBo goods);
     ResultVo<Long> insertGoodsSku(String userName , GoodsSkuNewAddBo goods);

    /**
     * 修改商品管理
     *
     * @param goods 商品管理
     * @return 结果
     */
     ResultVo updateGoods(OGoods goods);

    /**
     * 批量删除商品管理
     *
     * @param ids 需要删除的商品管理主键集合
     * @return 结果
     */
     int deleteGoodsByIds(Long[] ids);

    int insertGoodsSku(OGoodsSku goodsSku);
    int saveGoodsSku(GoodsSkuAddBo addBo);
    int batchSaveGoodsSku(List<GoodsSkuAddBo> list);

    /**
     * 商品状态变更操作（1上架2下架）
     * @param id
     * @param status
     * @return
     */
    int updateGoodsStatus(String id,Integer status,String userName);
    Long getCategoryGoodsTotal(Long categoryId);

    /**
     * 推送商品到商户
     * @param goodsId
     * @param merchantId
     * @return
     */
//    ResultVo pushGoodsToMerchant(Long goodsId, Long merchantId,String merchantNum);
}
