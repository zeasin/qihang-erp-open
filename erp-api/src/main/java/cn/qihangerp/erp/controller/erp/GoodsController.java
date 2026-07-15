package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.*;
import cn.qihangerp.model.entity.OGoods;
import cn.qihangerp.model.entity.OGoodsSku;
import cn.qihangerp.model.bo.GoodsAddBo;
import cn.qihangerp.model.query.GoodsQuery;
import cn.qihangerp.model.query.GoodsSkuQuery;
import cn.qihangerp.model.vo.GoodsSpecListVo;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.OGoodsService;
import cn.qihangerp.service.OGoodsSkuService;
import lombok.AllArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商品管理Controller
 * 
 * @author qihang
 * @date 2023-12-29
 */
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/goods")
public class GoodsController extends BaseController
{
    private final OGoodsService goodsService;
    private final OGoodsSkuService skuService;

    /**
     * 搜索商品SKU
     * 条件：商品编码、SKU、商品名称
     */
    @GetMapping("/searchSku")
    public TableDataInfo searchSkuBy(Long goodsId,String keyword)
    {
        if(goodsId!=null&&goodsId>0){
            List<OGoodsSku> oGoodsSkus = goodsService.querySkuByGoodsId(goodsId);
            return getDataTable(oGoodsSkus);
        }else {
            List<GoodsSpecListVo> list = goodsService.searchGoodsSpec(keyword);
            return getDataTable(list);
        }
    }

    @GetMapping("/sku_list")
    public TableDataInfo skuList(GoodsSkuQuery bo, PageQuery pageQuery)
    {
        var pageList = goodsService.querySkuPageList(bo,pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 查询商品管理列表
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:list')")
    @GetMapping("/list")
    public TableDataInfo list(GoodsQuery goods, PageQuery pageQuery)
    {
        PageResult<OGoods> pageList = goodsService.queryPageList(goods, pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 获取商品管理详细信息
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(goodsService.selectGoodsById(id));
    }
    /**
     * 获取商品管理详细信息
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:query')")
    @GetMapping(value = "/sku/{id}")
    public AjaxResult getSkuInfo(@PathVariable("id") Long id)
    {
        return success(skuService.getById(id));
    }
    /**
     * 新增商品管理
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:add')")
    @PostMapping("/add")
    public AjaxResult add(@RequestBody GoodsAddBo goods)
    {
        ResultVo<Long> resultVo = goodsService.insertGoods(getUsername(), goods);
        if(resultVo.getCode()!=0) return AjaxResult.error(resultVo.getMsg());
        else return AjaxResult.success(resultVo.getData());
//        goods.setCreateBy(getUsername());
//        int result = goodsService.insertGoods(goods);
//        if(result == -1) new AjaxResult(501,"商品编码已存在");
//        return toAjax(1);
    }

    @PreAuthorize("@ss.hasPermi('goods:goods:add')")
    @PostMapping("/goodsSku")
    public AjaxResult addSku(@RequestBody OGoodsSku goodsSku)
    {

        int result = goodsService.insertGoodsSku(goodsSku);
        if(result == -1) new AjaxResult(501,"商品编码已存在");
        return toAjax(1);
    }

    /**
     * 修改商品管理
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:edit')")
    @PutMapping
    public AjaxResult edit(@RequestBody OGoods goods) {
        var result = goodsService.updateGoods(goods);
        if(result.getCode()!=0) return AjaxResult.error(result.getMsg());
        else return AjaxResult.success();
    }

    /**
     * 修改商品基本资料
     * @param sku
     * @return
     */
    @PutMapping("/sku")
    public AjaxResult editSku(@RequestBody OGoodsSku sku)
    {
        String skuName="";
        if(StringUtils.hasText(sku.getColorValue())){
            skuName+=sku.getColorValue();
        }
        if(StringUtils.hasText(sku.getSizeValue())){
            skuName+=" "+sku.getSizeValue();
        }
        if(StringUtils.hasText(sku.getStyleValue())){
            skuName+=" "+sku.getStyleValue();
        }
        sku.setSkuName(skuName);

        return toAjax(skuService.updateById(sku));
    }

    /**
     * 删除商品管理
     */
    @PreAuthorize("@ss.hasPermi('goods:goods:remove')")
    @DeleteMapping("/del/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        int result = goodsService.deleteGoodsByIds(ids);
        if(result==0) return AjaxResult.success();
        else if (result==-100) return AjaxResult.error("有关联的订单，不能删除！");
        else return AjaxResult.error();
    }

//    @RequestMapping(value = "/api/erp-api/goods_sku_import", method = RequestMethod.POST)
//    public AjaxResult orderSendExcel(@RequestPart("file") MultipartFile file) throws IOException, InvalidFormatException {
//
//        String fileName = file.getOriginalFilename();
//        String dir = System.getProperty("user.dir");
//        String destFileName = dir + File.separator + "/import/uploadedfiles_" + fileName;
//        System.out.println(destFileName);
//        File destFile = new File(destFileName);
//        file.transferTo(destFile);
//        InputStream fis = null;
//        fis = new FileInputStream(destFileName);
//        if (fis == null) return AjaxResult.error("没有文件");
//
//        Workbook workbook = null;
//
//        try {
//            if (fileName.toLowerCase().endsWith("xlsx")) {
//                workbook = new XSSFWorkbook(fis);
//            } else if (fileName.toLowerCase().endsWith("xls")) {
//                workbook = new HSSFWorkbook(fis);
//            }
//            // workbook = new HSSFWorkbook(fis);
//        } catch (Exception ex) {
//            return AjaxResult.error(ex.getMessage());
//        }
//
//        if (workbook == null) return AjaxResult.error(502, "未读取到Excel文件");
//
//        /****************开始处理excel****************/
//        int success = 0;
//        int fail = 0;
//        Sheet sheet = null;
//        try {
//            sheet = workbook.getSheetAt(0);
//            int lastRowNum = sheet.getLastRowNum();//最后一行索引
//            Row row = null;
//
//            for (int i = 1; i <= lastRowNum; i++) {
//                row = sheet.getRow(i);
//                //数据
//                OGoodsSku  sku = new OGoodsSku();
//                for(int c=0;c<6;c++){
//                    Cell cell = row.getCell(c);
//                    String cellValue = "";
//                    if (cell != null) {
//                        if (cell.getCellType() == CellType.STRING) {
//                            cellValue = cell.getStringCellValue().replace("\t", "");
//                        } else if (cell.getCellType() == CellType.NUMERIC) {
//                            cellValue = NumberToTextConverter.toText(cell.getNumericCellValue()).replace("\t", "");
//                        }
//                    }
//                    if(c == 1) {
//                        if(StringUtils.hasText(cellValue) ){
//                            sku.setOuterErpGoodsId(cellValue);
//                        }else {
//                            sku.setOuterErpGoodsId("0");
//                        }
//                    }
//                    if(StringUtils.hasText(cellValue)) {
//                        if (c == 0) {
//                            sku.setOuterErpSkuId(cellValue);
//                        } else if (c == 2) {
//                            sku.setSkuCode(cellValue);
//                        } else if (c == 3) {
//                            sku.setSkuName(cellValue);
//                        } else if (c == 4) {
//                            sku.setColorImage(cellValue);
//                        } else if (c == 5) {
//                            sku.setRemark(cellValue);
//                        }
//                    }
//                }
//                goodsService.insertGoodsSku(sku);
//                success++;
//            }
//
//
//        } catch (Exception ex) {
//           fail++;
//            ex.printStackTrace();
//        }
//        Map<String, Integer> result = new HashMap<>();
//        result.put("success",success);
//        result.put("fail",fail);
//        return AjaxResult.success(result);
//    }
}
