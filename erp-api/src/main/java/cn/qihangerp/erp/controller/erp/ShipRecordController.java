package cn.qihangerp.erp.controller.erp;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.model.entity.OOrderStocking;
import cn.qihangerp.request.ShipRecordQueryRequest;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.OOrderStockingService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 统一发货记录查询 Controller
 * 根据 type 参数区分发货人类型：
 *   0   - 本地仓
 *   300 - 供应商
 *   100/110/200 - 云仓
 */
@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/erp-api/ship/record")
public class ShipRecordController extends BaseController {

    private final OOrderStockingService stockingService;

    /**
     * 统一发货记录分页查询
     * @param request 查询参数（含 type 区分发货人类型）
     * @param pageQuery 分页参数
     * @return 分页结果
     */
    @GetMapping("/record_list")
    public TableDataInfo recordList(ShipRecordQueryRequest request, PageQuery pageQuery) {
        PageResult<OOrderStocking> pageResult = stockingService.queryShipRecordPageList(request, pageQuery);
        return getDataTable(pageResult);
    }
}
