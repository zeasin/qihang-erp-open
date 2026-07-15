package cn.qihangerp.service;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.model.bo.SupplierProductAddBo;
import cn.qihangerp.model.bo.SupplierGoodsLinkBo;
import cn.qihangerp.model.entity.ErpSupplierProduct;
import cn.qihangerp.model.entity.ErpSupplierProductItem;
import com.baomidou.mybatisplus.extension.service.IService;

/**
* @author 1
* @description 针对表【erp_supplier_product(供应商商品表(SPU维度))】的数据库操作Service
* @createDate 2026-05-02 09:59:53
*/
public interface ErpSupplierProductService extends IService<ErpSupplierProduct> {

    /**
     * 分页查询供应商商品
     */
    PageResult<ErpSupplierProduct> queryPageList(ErpSupplierProduct goods, PageQuery pageQuery);

    /**
     * 添加供应商商品（含SKU）
     * @param username 操作人
     * @param bo 添加参数
     * @return 供应商商品ID
     */
    ResultVo<Long> addProduct(String username, SupplierProductAddBo bo);

    /**
     * 修改供应商商品（含SKU）
     * @param username 操作人
     * @param bo 修改参数
     */
    ResultVo updateProduct(String username, SupplierProductAddBo bo);

    /**
     * 删除供应商商品
     * @param id 商品ID
     */
    void deleteProduct(Long id);

    /**
     * 根据供应商商品ID查询SKU列表
     * @param supplierProductId 供应商商品ID
     * @return SKU列表
     */
    java.util.List<ErpSupplierProductItem> queryItemListByProductId(Long supplierProductId);

    /**
     * 修改供应商商品状态
     * @param id 商品ID
     * @param status 状态
     */
    void updateStatus(Long id, Integer status);

    /**
     * 从商品库关联商品到供应商
     * @param username 操作人
     * @param bo 关联参数（供应商ID + 商品库SPUID + SKU列表）
     * @return 操作结果
     */
    ResultVo linkGoodsFromLibrary(String username, SupplierGoodsLinkBo bo);
}
