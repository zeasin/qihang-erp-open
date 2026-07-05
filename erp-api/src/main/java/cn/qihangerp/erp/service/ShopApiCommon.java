package cn.qihangerp.erp.service;

import cn.qihangerp.common.ResultVo;
import cn.qihangerp.common.api.ShopApiParams;
import cn.qihangerp.enums.EnumShopType;
import cn.qihangerp.enums.HttpStatus;
import cn.qihangerp.model.entity.OShop;
import cn.qihangerp.model.entity.OShopPlatform;
import cn.qihangerp.service.OShopPlatformService;
import cn.qihangerp.service.OShopService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.Instant;

/**
 * 统一店铺 API 公共类：根据 shopType + shopId 获取 appKey/appSecret/accessToken。<br>
 * 支持平台：TAO/JD/PDD/DOU/WEI/KWAI/XHS。<br>
 * token 均由各平台 OAuthController 存到 {@link OShop#accessToken}，过期则返回 UNAUTHORIZED 提示重新授权。
 */
@Component
@RequiredArgsConstructor
public class ShopApiCommon {
    private final OShopService shopService;
    private final OShopPlatformService platformService;

    /**
     * 获取店铺 API 调用参数
     * @param shopId   店铺 id
     * @param shopType 店铺类型（由 OShop.type 传入，用于校验）
     * @return 参数封装
     */
    public ResultVo<ShopApiParams> checkBefore(Long shopId, Integer shopType) {
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error(HttpStatus.PARAMS_ERROR, "店铺不存在");
        if (shop.getType().intValue() != shopType.intValue()) {
            return ResultVo.error(HttpStatus.PARAMS_ERROR, "店铺类型不匹配");
        }

        String appKey = shop.getAppKey();
        String appSecret = shop.getAppSecret();
        if (!StringUtils.hasText(appKey) || !StringUtils.hasText(appSecret)) {
            OShopPlatform platform = platformService.selectById(shopType);
            if (platform != null) {
                if (!StringUtils.hasText(appKey)) appKey = platform.getAppKey();
                if (!StringUtils.hasText(appSecret)) appSecret = platform.getAppSecret();
            }
        }
        if (!StringUtils.hasText(appKey))  return ResultVo.error(HttpStatus.PARAMS_ERROR, "未配置 AppKey");
        if (!StringUtils.hasText(appSecret)) return ResultVo.error(HttpStatus.PARAMS_ERROR, "未配置 AppSecret");

        String accessToken = shop.getAccessToken();
        if (!StringUtils.hasText(accessToken)) {
            return ResultVo.error(500, "授权已过期，请重新授权");
        }

        // 检查token是否过期（通过expiresIn + accessTokenBegin判断）
        if (shop.getExpiresIn() != null && shop.getAccessTokenBegin() != null) {
            long elapsed = Instant.now().getEpochSecond() - shop.getAccessTokenBegin();
            if (elapsed >= shop.getExpiresIn()) {
                return ResultVo.error(500, "授权已过期，请重新授权");
            }
        }

        ShopApiParams params = new ShopApiParams();
        params.setAppKey(appKey);
        params.setAppSecret(appSecret);
        params.setAccessToken(accessToken);
        params.setServerUrl(shop.getApiRequestUrl());
        params.setSellerId(shop.getSellerId());
        params.setRedirectUri(shop.getApiCallbackUrl());
        return ResultVo.success(HttpStatus.SUCCESS, params);
    }

    /**
     * 简化调用：根据 shopId 自动判断 shopType，返回参数
     */
    public ResultVo<ShopApiParams> checkBefore(Long shopId) {
        OShop shop = shopService.getById(shopId);
        if (shop == null) return ResultVo.error(HttpStatus.PARAMS_ERROR, "店铺不存在");
        return checkBefore(shopId, shop.getType());
    }
}