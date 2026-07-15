import { defineStore } from 'pinia'
import router, { constantRoutes } from '@/router'
import { getRouters } from '@/api/menu'
import type { MenuRecord } from '@/api/menu'

const viewsMap: Record<string, () => Promise<any>> = {
  'Layout': () => import('@/layout/index.vue'),
  'ParentView': () => import('@/components/ParentView/index.vue'),
  'system/user/index': () => import('@/views/system/user/index.vue'),
  'system/user/authRole': () => import('@/views/system/user/authRole.vue'),
  'system/user/profile/index': () => import('@/views/system/user/profile/index.vue'),
  'system/role/index': () => import('@/views/system/role/index.vue'),
  'system/role/authUser': () => import('@/views/system/role/authUser.vue'),
  'system/role/selectUser': () => import('@/views/system/role/selectUser.vue'),
  'system/menu/index': () => import('@/views/system/menu/index.vue'),
  'system/dict/index': () => import('@/views/system/dict/index.vue'),
  'system/dict/data': () => import('@/views/system/dict/data.vue'),
  'system/config/index': () => import('@/views/system/config/index.vue'),
  'system/task/index': () => import('@/views/system/task/index.vue'),
  'goods/index': () => import('@/views/goods/index.vue'),
  'goods/goods_list': () => import('@/views/goods/goods_list.vue'),
  'goods/create_new': () => import('@/views/goods/create_new.vue'),
  'goods/spec/index': () => import('@/views/goods/spec/index.vue'),
  'goods/spec/add': () => import('@/views/goods/spec/add.vue'),
  'goods/category/index': () => import('@/views/goods/category/index.vue'),
  'goods/category/attribute': () => import('@/views/goods/category/categoryAttribute.vue'),
  'goods/category/attributeValue': () => import('@/views/goods/category/categoryAttributeValue.vue'),
  'goods/brand/index': () => import('@/views/goods/brand/index.vue'),
  'goods/shopGoods/index': () => import('@/views/goods/shopGoods/index.vue'),
  'goods/product_lib/index': () => import('@/views/goods/product_lib/index.vue'),
  'goods/product_lib/goods_list': () => import('@/views/goods/product_lib/goods_list.vue'),
  'goods/product_lib/create_new': () => import('@/views/goods/product_lib/create_new.vue'),
  'goods/product_lib/add_sku': () => import('@/views/goods/product_lib/add_sku.vue'),
  'goods/product_lib/sku_list': () => import('@/views/goods/product_lib/sku_list.vue'),
  'goods/PopupSkuList': () => import('@/views/goods/PopupSkuList.vue'),
  'vendor/product/index': () => import('@/views/vendor/product/index.vue'),
  'vendor/product/goods_list': () => import('@/views/vendor/product/goods_list.vue'),
  'vendor/product/goods_sku_list': () => import('@/views/vendor/product/goods_sku_list.vue'),
  'vendor/product/price': () => import('@/views/vendor/product/price.vue'),
  'vendor/supply/index': () => import('@/views/vendor/supply/index.vue'),
  'vendor/stock/index': () => import('@/views/vendor/stock/index.vue'),
  'vendor/customer/index': () => import('@/views/vendor/customer/index.vue'),
  'vendor/stockup/index': () => import('@/views/vendor/stockup/index.vue'),
  'supplier_product_list': () => import('@/views/vendor/product/goods_list.vue'),
  'purchase/order': () => import('@/views/purchase/order/index.vue'),
  'purchase/order/index': () => import('@/views/purchase/order/index.vue'),
  'purchase/order/list': () => import('@/views/purchase/order/list.vue'),
  'purchase/order/create': () => import('@/views/purchase/order/create.vue'),
  'purchase/order/detail': () => import('@/views/purchase/order/detail.vue'),
  'purchase/order/item': () => import('@/views/purchase/order/item.vue'),
  'purchase/order/stock_in': () => import('@/views/purchase/order/stock_in.vue'),
  'purchase/ship': () => import('@/views/purchase/ship/index.vue'),
  'purchase/ship/index': () => import('@/views/purchase/ship/index.vue'),
  'purchase/ship/create_stock_in_entry': () => import('@/views/purchase/ship/create_stock_in_entry.vue'),
  'purchase/shipper': () => import('@/views/purchase/shipper/index.vue'),
  'purchase/shipper/index': () => import('@/views/purchase/shipper/index.vue'),
  'goods/supplier/index': () => import('@/views/goods/supplier/index.vue'),

  // afterSale
  'afterSale/index': () => import('@/views/afterSale/index.vue'),

  // ai
  'ai/analysis': () => import('@/views/ai/analysis.vue'),
  'ai/config': () => import('@/views/ai/config.vue'),
  'ai/history': () => import('@/views/ai/history.vue'),

  // components
  'components/icons/index': () => import('@/views/components/icons/index.vue'),

  // library
  'library/logistics_company/index': () => import('@/views/library/logistics_company/index.vue'),

  // marketing
  'marketing/discount/index': () => import('@/views/marketing/discount/index.vue'),

  // member
  'member/index': () => import('@/views/member/index.vue'),

  // oauth
  'oauth/pdd_callback': () => import('@/views/oauth/pdd_callback.vue'),
  'oauth/weidian_callback': () => import('@/views/oauth/weidian_callback.vue'),

  // openAuth
  'openAuth/index': () => import('@/views/openAuth/index.vue'),

  // order
  'order/index': () => import('@/views/order/index.vue'),
  'order/order_list': () => import('@/views/order/order_list.vue'),
  'order/item_list': () => import('@/views/order/item_list.vue'),
  'order/shopOrder/index': () => import('@/views/order/shopOrder/index.vue'),

  // refund
  'refund/index': () => import('@/views/refund/index.vue'),
  'refund/shopRefund/index': () => import('@/views/refund/shopRefund/index.vue'),

  // report
  'report/goods/index': () => import('@/views/report/goods/index.vue'),
  'report/shop/index': () => import('@/views/report/shop/index.vue'),
  'report/stock/index': () => import('@/views/report/stock/index.vue'),

  // shipping
  'shipping/index': () => import('@/views/shipping/index.vue'),
  'shipping/manual_ship/order_list': () => import('@/views/shipping/manual_ship/order_list.vue'),
  'shipping/record/index': () => import('@/views/shipping/record/index.vue'),
  'shipping/logistics/index': () => import('@/views/shipping/logistics/index.vue'),
  'shipping/stocking/index': () => import('@/views/shipping/stocking/index.vue'),
  'shipping/ewaybillAccount/index': () => import('@/views/shipping/ewaybillAccount/index.vue'),
  'shipping/ewaybillAccount/': () => import('@/views/shipping/ewaybillAccount/index.vue'),
  'shipping/ewaybillAccount/account': () => import('@/views/shipping/ewaybillAccount/account.vue'),

  // shop
  'shop/index': () => import('@/views/shop/index.vue'),
  'shop/goods/index': () => import('@/views/shop/goods/index.vue'),
  'shop/goods/create': () => import('@/views/shop/goods/create.vue'),
  'shop/order/index': () => import('@/views/shop/order/index.vue'),
  'shop/refund/index': () => import('@/views/shop/refund/index.vue'),
  'shop/group/index': () => import('@/views/shop/group/index.vue'),
  'shop/merchant/index': () => import('@/views/shop/merchant/index.vue'),
  'shop/platform/index': () => import('@/views/shop/platform/index.vue'),
  'shop/region/index': () => import('@/views/shop/region/index.vue'),
  'shop/pull_log': () => import('@/views/shop/pull_log.vue'),

  // stock
  'stock/index': () => import('@/views/stock/index.vue'),

  // wms
  'wms/warehouse/index': () => import('@/views/wms/warehouse/index.vue'),
  'wms/warehouse/position': () => import('@/views/wms/warehouse/position.vue'),
  'wms/goods/index': () => import('@/views/wms/goods/index.vue'),
  'wms/goods/stored_goods_sku': () => import('@/views/wms/goods/stored_goods_sku.vue'),
  'wms/stockIn/index': () => import('@/views/wms/stockIn/index.vue'),
  'wms/stockOut/index': () => import('@/views/wms/stockOut/index.vue'),
  'wms/stock_alert/index': () => import('@/views/wms/stock_alert/index.vue'),
}

function loadView(view: string) {
  // 兼容带 .vue 后缀和不带后缀的情况
  const key = view.replace(/\.vue$/, '')
  if (viewsMap[key]) return viewsMap[key]
  console.error(`[permission.ts] 找不到组件: ${view}，请在 viewsMap 中添加该映射`)
  return () => import('@/views/error/ComponentNotFound.vue')
}

function filterAsyncRouter(routes: MenuRecord[]): any[] {
  return routes
    .filter((route) => route.component || route.children?.length)
    .map((route) => {
      const r: Record<string, any> = { ...route }
      if (r.component) {
        r.component = loadView(r.component)
      }
      if (r.children?.length) {
        r.children = filterAsyncRouter(r.children)
      } else {
        delete r.children
        delete r.redirect
      }
      return r
    })
}

export const usePermissionStore = defineStore('permission', {
  state: () => ({
    routes: [] as any[],
    addRoutes: [] as any[],
  }),
  actions: {
    async GenerateRoutes() {
      const res = await getRouters()
      const rewriteRoutes = filterAsyncRouter(res.data || [])
      rewriteRoutes.push({ path: '/:pathMatch(.*)*', redirect: '/404', hidden: true })
      rewriteRoutes.forEach((route) => router.addRoute(route))
      this.addRoutes = rewriteRoutes
      this.routes = constantRoutes.concat(rewriteRoutes)
      return rewriteRoutes
    },
    setSidebarRouters(routes: any[]) {
      this.routes = routes
    },
  },
})
