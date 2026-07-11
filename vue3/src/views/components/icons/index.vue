<template>
  <div class="icons-container">
    <el-tabs type="border-card">
      <el-tab-pane label="Icons">
        <div v-for="item of svgIcons" :key="item" class="icon-item">
          <el-tooltip placement="top" :content="generateIconCode(item)">
            <div class="icon-wrapper">
              <svg-icon :icon-class="item" class-name="disabled" />
              <span>{{ item }}</span>
            </div>
          </el-tooltip>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Element-UI Icons">
        <div v-for="item of elementIcons" :key="item" class="icon-item">
          <el-tooltip placement="top" :content="generateElementIconCode(item)">
            <div class="icon-wrapper">
              <i :class="'el-icon-' + item" />
              <span>{{ item }}</span>
            </div>
          </el-tooltip>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import svgIcons from './svg-icons'
import elementIcons from './element-icons'

function generateIconCode(symbol: string) {
  return `<svg-icon icon-class="${symbol}" />`
}
function generateElementIconCode(symbol: string) {
  return `<i class="el-icon-${symbol}" />`
}
</script>

<style lang="scss" scoped>
.icons-container {
  margin: 10px 20px 0;
  overflow: hidden;
  .icon-item {
    margin: 20px;
    height: 85px;
    text-align: center;
    width: 100px;
    float: left;
    font-size: 30px;
    color: #24292e;
    cursor: pointer;
  }
  .icon-wrapper span {
    display: block;
    font-size: 16px;
    margin-top: 10px;
  }
  .disabled {
    pointer-events: none;
  }
}
</style>
