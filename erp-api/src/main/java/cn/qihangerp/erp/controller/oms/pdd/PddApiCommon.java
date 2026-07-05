package cn.qihangerp.erp.controller.oms.pdd;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.ResultVoEnum;
import cn.qihangerp.common.api.ShopApiParams;
import cn.qihangerp.enums.EnumShopType;
import cn.qihangerp.enums.HttpStatus;
import cn.qihangerp.model.entity.OShop;
import cn.qihangerp.model.entity.OShopPlatform;
import cn.qihangerp.service.OShopPlatformService;
import cn.qihangerp.service.OShopService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 拼多多店铺 API 公共处理：<br>
 * 1. 校验店铺类型与参数配置；<br>
 * 2. 取出 accessToken（PDD access_token 有效期较长，过期需重新授权，这里不做自动刷新）。<br>
 * 统一 OMS 拉取流程中，PDD 平台店铺调用本类获取 appKey/appSecret/accessToken。
 */
@AllArgsConstructor
@Component
public class PddApiCommon {
    private final OShopService shopService;
    private final OShopPlatformService platformService;

    /**
     * 拉取前校验，返回 appKey/appSecret/accessToken 等参数
     */
    public ResultVo<ShopApiParams> checkBefore(Long shopId) {
        OShop shop = shopService.getById(shopId);
        if (shop == null) {
            return ResultVo.error(HttpStatus.PARAMS_ERROR, "参数错误，没有找到店铺");
        }
        if (shop.getType() != EnumShopType.PDD.getIndex()) {
            return ResultVo.error(HttpStatus.PARAMS_ERROR, "参数错误，店铺不是拼多多店铺");
        }

        // appKey/appSecret：优先取店铺级，没有则取平台级
        String appKey = shop.getAppKey();
        String appSecret = shop.getAppSecret();
        if (!StringUtils.hasText(appKey) || !StringUtils.hasText(appSecret)) {
            OShopPlatform platform = platformService.selectById(EnumShopType.PDD.getIndex());
            if (platform != null) {
                if (!StringUtils.hasText(appKey)) appKey = platform.getAppKey();
                if (!StringUtils.hasText(appSecret)) appSecret = platform.getAppSecret();
            }
        }
        if (!StringUtils.hasText(appKey)) {
            return ResultVo.error(HttpStatus.PARAMS_ERROR, "店铺配置错误，没有找到AppKey");
        }
        if (!StringUtils.hasText(appSecret)) {
            return ResultVo.error(HttpStatus.PARAMS_ERROR, "店铺配置错误，没有找到AppSecret");
        }

        // PDD 的 access_token，过期需重新授权
        String accessToken = shop.getAccessToken();
        if (!StringUtils.hasText(accessToken)) {
            return ResultVo.error(ResultVoEnum.UNAUTHORIZED.getIndex(), "拼多多授权已过期，请重新授权");
        }

        ShopApiParams params = new ShopApiParams();
        params.setAppKey(appKey);
        params.setAppSecret(appSecret);
        params.setAccessToken(accessToken);
        params.setServerUrl(shop.getApiRequestUrl());
        params.setSellerId(shop.getSellerId());
        return ResultVo.success(HttpStatus.SUCCESS, params);
    }
}
