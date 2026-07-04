<template>
  <div class="app-container">

    <print-tao v-if="shopType === 100" />
    <!--        <print-jd v-if="shopType === 200"></print-jd>-->
    <!--        <print-jdvc v-if="shopType === 280"></print-jdvc>-->
    <print-jd v-if="shopType === 200" :shop-type="200" />
    <print-jd v-if="shopType === 280" :shop-type="280" />
    <print-pdd v-if="shopType === 300" />
    <print-dou v-if="shopType === 400" />
    <print-wei v-if="shopType === 500" />
    <print-ks v-if="shopType === 600" />
    <print-xhs v-if="shopType === 700" />
    <print-list v-if="shopType === 999" />

  </div>
</template>

<script>
import printTao from '@/views/shipping/ewaybillPrint/tao/index.vue'
import printPdd from '@/views/shipping/ewaybillPrint/pdd/index.vue'
import printDou from '@/views/shipping/ewaybillPrint/dou/index.vue'
import printJd from '@/views/shipping/ewaybillPrint/jd/index.vue'
import printJdvc from '@/views/shipping/ewaybillPrint/jd/vc-order.vue'
import printWei from '@/views/shipping/ewaybillPrint/wei/index.vue'
import CountTo from 'vue-count-to'
import { getShop, listPlatform } from '@/api/shop/shop'
import { waitOrderReport } from '@/api/order/order'
import { todayWaybillList } from '@/api/order/ship_order'
import printXhs from '@/views/shipping/ewaybillPrint/xhs/index.vue'
import printKs from '@/views/shipping/ewaybillPrint/ks/index.vue'
import { getUserProfile } from '@/api/system/user'
export default {
  name: 'Print',
  components: {
    printKs, printXhs, CountTo,
    printTao, printPdd, printDou, printJd, printWei, printJdvc },
  data() {
    return {
      shopId: null,
      shopType: 0,
      shopName: null,
      merchantId: null
    }
  },
  created() {

  },
  mounted() {
    getUserProfile().then(res => {
      this.loading = false
      if (res.data.userType == 40) {
        getShop(res.data.deptId).then(response => {
          console.log(response)
          if (response.data) {
            this.shopId = response.data.id
            this.merchantId = response.data.merchantId
            this.shopName = response.data.name
            this.shopType = response.data.type
          }
        })
      } else {
        this.$modal.msgError('非店铺用户')
      }
    })
  },
  methods: {

  }
}
</script>

<style lang="scss" scoped>
.panel-group {
  margin-top: 18px;

  .card-panel-col {
    margin-bottom: 32px;
  }

  .card-panel {
    height: 108px;
    cursor: pointer;
    font-size: 12px;
    position: relative;
    overflow: hidden;
    color: #666;
    background: #fff;
    box-shadow: 4px 4px 40px rgba(0, 0, 0, .05);
    border-color: rgba(0, 0, 0, .05);

    &:hover {
      .card-panel-icon-wrapper {
        color: #fff;
      }

      .icon-people {
        background: #40c9c6;
      }

      .icon-message {
        background: #36a3f7;
      }

      .icon-money {
        background: #f4516c;
      }

      .icon-shopping {
        background: #34bfa3
      }
    }

    .icon-people {
      color: #40c9c6;
    }

    .icon-message {
      color: #36a3f7;
    }

    .icon-money {
      color: #f4516c;
    }

    .icon-shopping {
      color: #34bfa3
    }

    .card-panel-icon-wrapper {
      float: left;
      margin: 14px 0 0 14px;
      padding: 16px;
      transition: all 0.38s ease-out;
      border-radius: 6px;
    }

    .card-panel-icon {
      float: left;
      font-size: 48px;
    }

    .card-panel-description {
      float: right;
      font-weight: bold;
      margin: 26px;
      margin-left: 0px;

      .card-panel-text {
        line-height: 18px;
        color: rgba(0, 0, 0, 0.45);
        font-size: 16px;
        margin-bottom: 12px;
      }

      .card-panel-num {
        font-size: 20px;
      }
    }
  }
}

@media (max-width:550px) {
  .card-panel-description {
    display: none;
  }

  .card-panel-icon-wrapper {
    float: none !important;
    width: 100%;
    height: 100%;
    margin: 0 !important;

    .svg-icon {
      display: block;
      margin: 14px auto !important;
      float: none !important;
    }
  }
}
</style>
