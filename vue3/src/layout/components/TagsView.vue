<template>
  <div class="tags-view-container">
    <el-scrollbar>
      <div class="tags-view-wrapper">
        <router-link
          v-for="tag in visitedViews"
          :key="tag.path"
          :class="isActive(tag.path) ? 'active' : ''"
          :to="{ path: tag.path, query: tag.query }"
          class="tags-view-item"
          @click.middle="closeSelectedTag(tag)"
        >
          {{ tag.title }}
          <el-icon v-if="!isAffix(tag)" class="el-icon-close" @click.prevent.stop="closeSelectedTag(tag)">
            <Close />
          </el-icon>
        </router-link>
      </div>
    </el-scrollbar>
    <div class="contextmenu" v-show="visible" :style="{ left: left + 'px', top: top + 'px' }">
      <el-dropdown trigger="click" @command="handleCommand">
        <el-button>操作</el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="refresh" icon="Refresh">刷新</el-dropdown-item>
            <el-dropdown-item command="closeRight" icon="ArrowRightBold">关闭右侧</el-dropdown-item>
            <el-dropdown-item command="closeOther" icon="CircleClose">关闭其他</el-dropdown-item>
            <el-dropdown-item command="closeAll" icon="FolderDelete">关闭所有</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Close } from '@element-plus/icons-vue'
import { useTagsViewStore } from '@/store/modules/tagsView'
import type { TagView } from '@/store/modules/tagsView'

const route = useRoute()
const router = useRouter()
const tagsViewStore = useTagsViewStore()

const visitedViews = computed(() => tagsViewStore.visitedViews)
const visible = ref(false)
const left = ref(0)
const top = ref(0)

function isActive(path: string): boolean {
  return path === route.path
}

function isAffix(tag: TagView): boolean {
  return tag.meta?.affix === true
}

function closeSelectedTag(tag: TagView) {
  tagsViewStore.delView(tag)
  if (isActive(tag.path)) {
    toLastView(tagsViewStore.visitedViews, tag)
  }
}

function toLastView(visited: TagView[], view: TagView) {
  const latestView = visited.slice(-1)[0]
  if (latestView) {
    router.push(latestView.path!)
  } else {
    router.push('/')
  }
}

function handleCommand(command: string) {
  const tag = visitedViews.value.find((t) => t.path === route.path)
  if (!tag) return
  switch (command) {
    case 'refresh':
      tagsViewStore.delCachedView(tag)
      router.push({ path: '/redirect' + route.path })
      break
    case 'closeRight':
      tagsViewStore.delOthersViews(tag)
      break
    case 'closeOther':
      tagsViewStore.delOthersViews(tag)
      break
    case 'closeAll':
      tagsViewStore.delAllViews()
      router.push('/')
      break
  }
  visible.value = false
}
</script>

<style lang="scss" scoped>
.tags-view-container {
  height: 34px;
  width: 100%;
  background: #fff;
  border-bottom: 1px solid #d8dce5;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 0 3px rgba(0, 0, 0, 0.04);

  .tags-view-wrapper {
    display: flex;
    align-items: center;
    white-space: nowrap;
    position: relative;
  }

  .tags-view-item {
    display: inline-flex;
    align-items: center;
    padding: 0 8px;
    font-size: 12px;
    color: #495060;
    border: 1px solid #d8dce5;
    height: 26px;
    line-height: 26px;
    margin-left: 5px;
    cursor: pointer;
    text-decoration: none;
    border-radius: 3px;

    &:first-of-type {
      margin-left: 10px;
    }

    &.active {
      background-color: #409eff;
      color: #fff;
      border-color: #409eff;

      .el-icon-close {
        color: #fff;
      }
    }

    .el-icon-close {
      width: 16px;
      height: 16px;
      margin-left: 4px;
      border-radius: 50%;
      transition: all 0.3s;
      font-size: 12px;
      display: inline-flex;
      align-items: center;
      justify-content: center;

      &:hover {
        background-color: rgba(0, 0, 0, 0.2);
        color: #fff;
      }
    }
  }
}
</style>
