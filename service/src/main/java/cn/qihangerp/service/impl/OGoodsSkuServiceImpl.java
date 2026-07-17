package cn.qihangerp.service.impl;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.mapper.OGoodsSkuMapper;
import cn.qihangerp.service.OGoodsSkuService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.model.entity.OGoodsSku;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
* @author TW
* @description 针对表【o_goods_sku(商品规格库存管理)】的数据库操作Service实现
* @createDate 2024-03-11 14:24:49
*/
@AllArgsConstructor
@Service
public class OGoodsSkuServiceImpl extends ServiceImpl<OGoodsSkuMapper, OGoodsSku>
    implements OGoodsSkuService {
    private final OGoodsSkuMapper skuMapper;

    @Override
    public List<OGoodsSku> searchGoodsSpec(String keyword) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper =
                new LambdaQueryWrapper<OGoodsSku>()
                        .likeRight(OGoodsSku::getGoodsId,keyword).or()
                        .likeRight(OGoodsSku::getId,keyword).or()
                        .likeRight(OGoodsSku::getSkuCode,keyword).or()
                        .like(OGoodsSku::getGoodsName,keyword).or()
                        .like(OGoodsSku::getSkuName,keyword)
                ;
        queryWrapper.last("LIMIT 10");
        return skuMapper.selectList(queryWrapper);
    }

    @Override
    public List<OGoodsSku> selectSkuAll(Long merchantId) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper =
                new LambdaQueryWrapper<OGoodsSku>()
                        .eq(merchantId!=null,OGoodsSku::getMerchantId,merchantId)
                ;

        return skuMapper.selectList(queryWrapper);
    }

    @Override
    public OGoodsSku getGoodsSkuByCode(String skuCode) {
        LambdaQueryWrapper<OGoodsSku> qw = new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getSkuCode,skuCode);
        List<OGoodsSku> oGoodsSkus = skuMapper.selectList(qw);
        if(oGoodsSkus.isEmpty()) return null;
        else return oGoodsSkus.get(0);
    }

    @Override
    public OGoodsSku getGoodsSkuByOuterSkuCode(String outerSkuCode) {
        LambdaQueryWrapper<OGoodsSku> qw = new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getOuterErpSkuId,outerSkuCode);
        List<OGoodsSku> oGoodsSkus = skuMapper.selectList(qw);
        if(oGoodsSkus.isEmpty()) return null;
        else return oGoodsSkus.get(0);
    }

    @Override
    public ResultVo updateSku(OGoodsSku sku) {
        if(sku.getMerchantId()>0){
            // 商户的商品，要判断商品库SKUID是否存在
            if(StringUtils.hasText(sku.getOuterErpSkuId())) {
                OGoodsSku oGoodsSku = skuMapper.selectById(sku.getOuterErpSkuId());
                if(oGoodsSku==null) return ResultVo.error("商品库商品SkuID不存在");
                else if(oGoodsSku.getMerchantId()!=0) return ResultVo.error("商品库商品SkuID不存在");
            }
        }
        String skuName="";
        if(StringUtils.hasText(sku.getColorValue())){
            skuName+= sku.getColorValue();
        }
        if (StringUtils.hasText(sku.getSizeValue())) {
            skuName+=" "+sku.getSizeValue();
        }
        if (StringUtils.hasText(sku.getStyleValue())) {
            skuName+=" "+sku.getStyleValue();
        }
        sku.setSkuName(skuName);
        // 开始更新
        skuMapper.updateById(sku);
        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo deleteSkuById(Long skuId) {
        skuMapper.deleteById(skuId);
        return ResultVo.success();
    }
}




