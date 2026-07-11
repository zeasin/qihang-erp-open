<template>
  <div class="component-not-found">
    <h1>找不到组件</h1>
    <p>请查看控制台输出的错误信息，检查 <code>permission.ts</code> 的 <code>viewsMap</code> 中是否缺少相关映射</p>
  </div>
</template>

<style scoped>
.component-not-found {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #f56c6c;
}
.component-not-found h1 {
  font-size: 24px;
  margin-bottom: 16px;
}
.component-not-found p {
  font-size: 14px;
  color: #666;
  margin: 4px 0;
}
.component-not-found code {
  background: #fef0f0;
  padding: 2px 8px;
  border-radius: 4px;
  color: #f56c6c;
}
</style>
