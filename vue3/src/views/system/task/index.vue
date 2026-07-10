<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="任务名称" prop="taskName">
        <el-input v-model="queryParams.taskName" placeholder="请输入任务名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="taskList">
      <el-table-column label="ID" align="center" prop="id" width="100" />
      <el-table-column label="任务名称" align="left" prop="taskName" />
      <el-table-column label="表达式（-表示不运行）" align="center" prop="cron" />
      <el-table-column label="执行函数" align="center" prop="method" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="200">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['system:notice:edit']"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleViewLogs(scope.row.id)"><el-icon><View /></el-icon>查看日志</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="任务运行日志" v-model="logOpen" width="1080px" append-to-body>
      <el-table v-loading="logLoading" :data="logList">
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="执行结果" align="left" prop="result" width="450px" />
        <el-table-column label="开始时间" align="center" prop="startTime">
          <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
        </el-table-column>
        <el-table-column label="结束时间" align="center" prop="endTime">
          <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
        </el-table-column>
        <el-table-column label="状态" align="center" prop="status">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 1">运行中</el-tag>
            <el-tag v-if="scope.row.status === 2">已完成</el-tag>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="logTotal > 0" :total="logTotal" v-model:page="logPageNum" v-model:limit="logPageSize" @pagination="handleViewLogs(taskId)" />
    </el-dialog>

    <el-dialog :title="title" v-model="open" width="780px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="180px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="任务名称" prop="taskName">
              <el-input v-model="form.taskName" placeholder="请输入任务名称" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="表达式（-表示不运行）" prop="cron">
              <el-input v-model="form.cron" placeholder="请输入表达式（-表示不运行）" />
              <el-select v-model="cronType" @change="cronTypeChange" placeholder="表达式选择" style="width: 200px; margin-left: 10px">
                <el-option label="不运行" value="0" />
                <el-option label="1分钟运行一次" value="1" />
                <el-option label="3分钟运行一次" value="3" />
                <el-option label="5分钟运行一次" value="5" />
                <el-option label="10分钟运行一次" value="10" />
                <el-option label="30分钟运行一次" value="30" />
                <el-option label="1小时运行一次" value="60" />
                <el-option label="12小时运行一次" value="720" />
                <el-option label="24小时运行一次" value="1440" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="执行函数" prop="method">
              <el-input v-model="form.method" placeholder="请输入执行函数" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="内容">
              <el-input type="textarea" v-model="form.remark" :autosize="{ minRows: 4 }" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Edit, View } from '@element-plus/icons-vue'
import { listTask, updateTask, getTask, getTaskLogs } from '@/api/system/task'
import { parseTime } from '@/utils/zhijian'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const logLoading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const logTotal = ref(0)
const taskList = ref<any[]>([])
const logList = ref<any[]>([])
const logOpen = ref(false)
const title = ref('')
const open = ref(false)
const taskId = ref<number>()
const logPageNum = ref(1)
const logPageSize = ref(20)
const cronType = ref(undefined)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  id: undefined,
  taskName: undefined,
  cron: undefined,
  method: undefined,
  remark: undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  noticeTitle: undefined,
  status: undefined
})

const rules = {
  taskName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  cron: [{ required: true, message: '不能为空', trigger: 'change' }]
}

watch(logOpen, (val) => {
  if (!val) {
    taskId.value = undefined
  }
})

onMounted(() => { getList() })

function cronTypeChange() {
  if (cronType.value === 0) {
    form.cron = '-'
  } else if (cronType.value === 1) {
    form.cron = '0 0/1 * * * ?'
  } else if (cronType.value === 3) {
    form.cron = '0 0/3 * * * ?'
  } else if (cronType.value === 5) {
    form.cron = '0 0/5 * * * ?'
  } else if (cronType.value === 10) {
    form.cron = '0 0/10 * * * ?'
  } else if (cronType.value === 30) {
    form.cron = '0 0/30 * * * ?'
  } else if (cronType.value === 60) {
    form.cron = '0 0 0/1 * * ?'
  } else if (cronType.value === 720) {
    form.cron = '0 0 0/12 * * ?'
  } else if (cronType.value === 1440) {
    form.cron = '0 0 0 0/1 * ?'
  }
}

function getList() {
  loading.value = true
  listTask(queryParams).then((res: any) => {
    taskList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  taskId.value = undefined
  reset()
}

function reset() {
  form.id = undefined
  form.taskName = undefined
  form.cron = undefined
  form.method = undefined
  form.remark = undefined
  cronType.value = undefined
  formRef.value?.resetFields()
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleViewLogs(id: number) {
  taskId.value = id
  getTaskLogs(id).then((res: any) => {
    logList.value = res.data?.records || []
    logTotal.value = res.data?.total || 0
    logLoading.value = false
    logOpen.value = true
  })
}

function handleUpdate(row: any) {
  reset()
  const id = row.id
  getTask(id).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
    title.value = '修改'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      updateTask({ ...form }).then(() => {
        ElMessage.success('修改成功')
        open.value = false
        getList()
      })
    }
  })
}
</script>
