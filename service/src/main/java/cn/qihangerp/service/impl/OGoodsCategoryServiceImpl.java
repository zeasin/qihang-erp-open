package cn.qihangerp.service.impl;

import cn.qihangerp.model.entity.OGoodsCategoryAttribute;
import cn.qihangerp.model.entity.OGoodsCategoryAttributeValue;
import cn.qihangerp.mapper.OGoodsCategoryAttributeMapper;
import cn.qihangerp.mapper.OGoodsCategoryAttributeValueMapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.model.entity.OGoodsCategory;
import cn.qihangerp.service.OGoodsCategoryService;
import cn.qihangerp.mapper.OGoodsCategoryMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
* @author qilip
* @description 针对表【o_goods_category】的数据库操作Service实现
* @createDate 2024-09-07 16:11:56
*/
@AllArgsConstructor
@Service
public class OGoodsCategoryServiceImpl extends ServiceImpl<OGoodsCategoryMapper, OGoodsCategory>
    implements OGoodsCategoryService{
    private final OGoodsCategoryMapper oGoodsCategoryMapper;
    private final OGoodsCategoryAttributeMapper attributeMapper;
    private final OGoodsCategoryAttributeValueMapper attributeValueMapper;

    /**
     * 统一字段补齐 + 超长安全截断
     * @param category 分类实体
     * @param isUpdate 是否为更新操作
     */
    private void fillRequiredFields(OGoodsCategory category, boolean isUpdate) {
        // 1. NOT NULL 字段兜底（避免500）
        if (category.getMerchantId() == null) {
            category.setMerchantId(0L); // 默认0=总部系统
        }
        if (category.getParentId() == null) {
            category.setParentId(0L); // 默认0=一级分类
        }
        if (category.getSort() == null) {
            category.setSort(0);
        }
        if (category.getIsdelete() == null) {
            category.setIsdelete(0);
        }
        if (category.getPath() == null) {
            category.setPath("");
        }
        // 2. 长度严格截断（按用户要求：编码18/名称20/备注50）
        if (category.getNumber() != null && category.getNumber().length() > 18) {
            category.setNumber(category.getNumber().substring(0, 18));
        }
        if (category.getName() != null && category.getName().length() > 20) {
            category.setName(category.getName().substring(0, 20));
        }
        if (category.getRemark() != null && category.getRemark().length() > 50) {
            category.setRemark(category.getRemark().substring(0, 50));
        }
        if (category.getPath() != null && category.getPath().length() > 500) {
            category.setPath(category.getPath().substring(0, 500));
        }
        // 3. 时间戳
        LocalDateTime now = LocalDateTime.now();
        if (!isUpdate) {
            category.setCreateTime(now);
        }
        category.setUpdateTime(now);
    }

    @Transactional
    @Override
    public void addCategory(OGoodsCategory category) {
        // 统一补齐字段 + 长度截断（防止500 + 防止超长入库失败）
        fillRequiredFields(category, false);
        // 添加分类
        oGoodsCategoryMapper.insert(category);
        // 如果是一级分类，添加默认规格
        if(category.getParentId()==0) {
            // 添加颜色规格
            OGoodsCategoryAttribute att1 = new OGoodsCategoryAttribute();
            att1.setCategoryId(category.getId());
            att1.setType(1);
            att1.setTitle("颜色");
            att1.setCode("color");
            attributeMapper.insert(att1);
            // 添加颜色规格值
            OGoodsCategoryAttributeValue av1 = new OGoodsCategoryAttributeValue();
            av1.setCategoryAttributeId(att1.getId());
            av1.setValue("默认");
            av1.setSkuCode("00");
            av1.setOrdernum(0);
            av1.setIsdelete(0);
            attributeValueMapper.insert(av1);
        }
    }

    /**
     * 重写MyBatis-Plus的updateById，确保统一字段补齐+长度截断
     */
    @Transactional
    @Override
    public boolean updateById(OGoodsCategory category) {
        fillRequiredFields(category, true);
        return super.updateById(category);
    }
}
