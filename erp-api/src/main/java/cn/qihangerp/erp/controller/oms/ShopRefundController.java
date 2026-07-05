package cn.qihangerp.erp.controller.oms;

import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.TableDataInfo;
import cn.qihangerp.erp.service.ShopPullApiService;
import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.model.request.RefundPullRequest;
import cn.qihangerp.security.common.BaseController;
import cn.qihangerp.service.ORefundService;
import cn.qihangerp.service.ShopRefundService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@AllArgsConstructor
@RestController
@RequestMapping("/api/oms-api/shop/refund")
public class ShopRefundController extends BaseController {

    private final ShopRefundService shopRefundService;
    private final ORefundService oRefundService;
    private final ShopPullApiService shopPullApiService;

    @GetMapping("/list")
    public TableDataInfo list(ShopRefund bo, PageQuery pageQuery) {
        PageResult<ShopRefund> pageList = shopRefundService.queryPageList(bo, pageQuery);
        return getDataTable(pageList);
    }

    /**
     * 拉取店铺售后列表（根据 shopType 路由到对应平台 SDK）。
     * 前端：{@code /api/oms-api/shop/refund/pull_list}，参数 {shopId}
     */
    @PostMapping("/pull_list")
    public AjaxResult pullList(@RequestBody RefundPullRequest req) {
        ResultVo<String> result = shopPullApiService.pullRefund(req.getShopId());
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getCode(), result.getMsg());
    }

    /**
     * 拉取单个售后详情并同步。
     * 前端：{@code /api/oms-api/shop/refund/pull_detail}，参数 {shopId, refundId}
     */
    @PostMapping("/pull_detail")
    public AjaxResult pullDetail(@RequestBody RefundPullRequest req) {
        ResultVo<String> result = shopPullApiService.pullRefundDetail(req.getShopId(),
                StringUtils.hasText(req.getAfterId()) ? req.getAfterId() : req.getRefundId());
        if (result.getCode() == 0) {
            return AjaxResult.success(result.getMsg());
        }
        return AjaxResult.error(result.getCode(), result.getMsg());
    }

    /**
     * 推送到 OMS（同步 oms_shop_refund → o_refund）。
     * 前端：{@code /api/oms-api/shop/refund/push_oms}，参数 {ids:[shopRefundId...]}
     */
    @PostMapping("/push_oms")
    public AjaxResult pushOms(@RequestBody Map<String, Object> body) {
        Object idsObj = body.get("ids");
        if (idsObj == null) {
            return AjaxResult.error("参数错误，缺少ids");
        }
        @SuppressWarnings("unchecked")
        List<Object> ids = (List<Object>) idsObj;
        int success = 0, fail = 0;
        for (Object id : ids) {
            try {
                Long shopRefundId = Long.parseLong(String.valueOf(id));
                ResultVo<Long> r = oRefundService.shopRefundMessage(shopRefundId);
                if (r.getCode() == 0) success++;
                else fail++;
            } catch (Exception e) {
                log.error("推送售后到OMS异常：{}", id, e);
                fail++;
            }
        }
        return AjaxResult.success("同步完成，成功：" + success + "条，失败：" + fail + "条");
    }
}
