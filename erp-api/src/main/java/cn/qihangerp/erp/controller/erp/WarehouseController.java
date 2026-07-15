package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.entity.ErpWarehouse;
import cn.qihangerp.model.entity.ErpWarehousePosition;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.ErpWarehousePositionService;
import cn.qihangerp.service.ErpWarehouseService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.time.LocalDateTime;
import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/warehouse")
public class WarehouseController extends BaseController {
    private final ErpWarehouseService warehouseService;
    private final ErpWarehousePositionService positionService;
    @GetMapping("/list")
    public TableDataInfo list(ErpWarehouse bo)
    {
        LambdaQueryWrapper<ErpWarehouse> qw = new LambdaQueryWrapper<ErpWarehouse>()
                .eq(bo.getStatus()!=null, ErpWarehouse::getStatus, bo.getStatus())
                .like(StringUtils.hasText(bo.getWarehouseNo()), ErpWarehouse::getWarehouseNo,bo.getWarehouseNo())
                .like(StringUtils.hasText(bo.getWarehouseName()), ErpWarehouse::getWarehouseName,bo.getWarehouseName())
                ;
        List<ErpWarehouse> erpWarehouses = warehouseService.list(qw);
        return getDataTable(erpWarehouses);
    }

    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(warehouseService.getById(id));
    }
    @PostMapping
    public AjaxResult add(@RequestBody ErpWarehouse warehouse)
    {
        warehouse.setCreateBy(getUsername());
        warehouse.setCreateTime(LocalDateTime.now());
        boolean save = warehouseService.save(warehouse);
        if(save){
            ErpWarehousePosition position = new ErpWarehousePosition();
            position.setWarehouseId(warehouse.getId());
            position.setParentId(0l);
            position.setParentId1(0l);
            position.setParentId2(0l);
            position.setNumber(warehouse.getWarehouseNo());
            position.setName(warehouse.getWarehouseName());
            position.setIsDelete(0);
            position.setAddress(warehouse.getAddress());
            position.setRemark(warehouse.getRemark());
            position.setCreateBy(getUsername());
            position.setCreateTime(LocalDateTime.now());
            positionService.save(position);
        }
        return AjaxResult.success();
    }
    @PutMapping
    public AjaxResult edit(@RequestBody ErpWarehouse warehouse)
    {
        warehouse.setUpdateBy(getUsername());
        warehouse.setUpdateTime(LocalDateTime.now());
        return toAjax(warehouseService.updateById(warehouse));
    }
	@DeleteMapping("/{ids}")
	public AjaxResult remove(@PathVariable Long[] ids)
	{
	    return toAjax(warehouseService.removeBatchByIds(Arrays.stream(ids).toList()));
	}

	/**
     * 查询云仓列表（用于发货云仓选择，排除本地仓 LOCAL）
     */
    @GetMapping("/cloud_list")
    public TableDataInfo cloudList()
    {
        LambdaQueryWrapper<ErpWarehouse> qw = new LambdaQueryWrapper<ErpWarehouse>()
                .ne(ErpWarehouse::getWarehouseType, "LOCAL")
                .eq(ErpWarehouse::getStatus, 1)
                .orderByDesc(ErpWarehouse::getCreateTime);
        List<ErpWarehouse> list = warehouseService.list(qw);
        return getDataTable(list);
    }

    /**
     * 查询所有可用仓库（仅总部查询）
     */
    @GetMapping("/my_available_list")
    public AjaxResult myAvailableList()
	{
	    LambdaQueryWrapper<ErpWarehouse> qw = new LambdaQueryWrapper<ErpWarehouse>()
	            .eq(ErpWarehouse::getStatus, 1);
	    List<ErpWarehouse> list = warehouseService.list(qw);
	    return success(list);
	}

	@GetMapping("/position/list")
    public TableDataInfo positionList(Long warehouseId)
    {
        LambdaQueryWrapper<ErpWarehousePosition> qw = new LambdaQueryWrapper<ErpWarehousePosition>()
                .eq(ErpWarehousePosition::getWarehouseId,warehouseId)
                ;
        List<ErpWarehousePosition> list = positionService.list(qw);
        return getDataTable(list);
    }
    @GetMapping("/position/search")
    public TableDataInfo searchPosition(Long warehouseId,String number)
    {
        LambdaQueryWrapper<ErpWarehousePosition> qw = new LambdaQueryWrapper<ErpWarehousePosition>()
                .eq(ErpWarehousePosition::getWarehouseId,warehouseId)
                .like(ErpWarehousePosition::getNumber,number)
                ;
        List<ErpWarehousePosition> list = positionService.list(qw);
        return getDataTable(list);
    }


    @PostMapping("/position")
    public AjaxResult positionAdd(@RequestBody ErpWarehousePosition position) {
        position.setCreateBy(getUsername());
        position.setCreateTime(LocalDateTime.now());
        position.setParentId1(0l);
        position.setParentId2(0l);
        positionService.save(position);

        return AjaxResult.success();
    }

    @GetMapping(value = "/position/{id}")
    public AjaxResult getPositionInfo(@PathVariable("id") Long id)
    {
        return success(positionService.getById(id));
    }

    @PutMapping("/position")
    public AjaxResult positionEdit(@RequestBody ErpWarehousePosition position)
    {
        position.setUpdateBy(getUsername());
        position.setUpdateTime(LocalDateTime.now());
        return toAjax(positionService.updateById(position));
    }
    @DeleteMapping("/position/{ids}")
    public AjaxResult positionRemove(@PathVariable Long[] ids)
    {
        return toAjax(positionService.removeBatchByIds(Arrays.stream(ids).toList()));
    }

}
