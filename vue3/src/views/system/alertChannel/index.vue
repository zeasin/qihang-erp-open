<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :disabled="single" @click="handleUpdate"><el-icon><Edit /></el-icon>修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain size="small" :disabled="multiple" @click="handleDelete"><el-icon><Delete /></el-icon>删除</el-button>
      </el-col>
      <right-toolbar @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="渠道名称" align="center" prop="channelName" min-width="140" />
      <el-table-column label="渠道类型" align="center" prop="channelType" width="120">
        <template #default="scope">
          <el-tag :type="scope.row.channelType === 'FEISHU' ? 'primary' : scope.row.channelType === 'DINGTALK' ? 'warning' : 'success'">
            {{ scope.row.channelType === 'FEISHU' ? '飞书' : scope.row.channelType === 'DINGTALK' ? '钉钉' : scope.row.channelType === 'WECHAT' ? '企微' : scope.row.channelType }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="Webhook地址" align="center" prop="webhookUrl" min-width="280" show-overflow-tooltip />
      <el-table-column label="密钥" align="center" prop="secret" min-width="160" show-overflow-tooltip />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">{{ scope.row.status === 1 ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="240" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleTest(scope.row)"><el-icon><Promotion /></el-icon>测试</el-button>
          <el-button size="small" type="text" @click="handleUpdate(scope.row)"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="560px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="渠道名称" prop="channelName">
          <el-input v-model="form.channelName" placeholder="请输入渠道名称" />
        </el-form-item>
        <el-form-item label="渠道类型" prop="channelType">
          <el-select v-model="form.channelType" placeholder="请选择渠道类型" style="width: 100%">
            <el-option label="飞书" value="FEISHU" />
            <el-option label="钉钉" value="DINGTALK" />
            <el-option label="企业微信" value="WECHAT" />
          </el-select>
        </el-form-item>
        <el-form-item label="Webhook地址" prop="webhookUrl">
          <el-input v-model="form.webhookUrl" placeholder="请输入Webhook地址" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="密钥" prop="secret">
          <el-input v-model="form.secret" placeholder="钉钉机器人需填写签名密钥（可选）" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete, Promotion } from '@element-plus/icons-vue'
import { listChannel, getChannel, addChannel, updateChannel, delChannel, testChannel } from '@/api/system/alertChannel'
import { parseTime } from '@/utils/zhijian'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const list = ref<any[]>([])
const title = ref('')
const open = ref(false)
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  id: undefined,
  channelName: undefined,
  channelType: undefined,
  webhookUrl: undefined,
  secret: undefined,
  status: 1
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10
})

const rules = {
  channelName: [{ required: true, message: '渠道名称不能为空', trigger: 'blur' }],
  channelType: [{ required: true, message: '请选择渠道类型', trigger: 'change' }],
  webhookUrl: [{ required: true, message: 'Webhook地址不能为空', trigger: 'blur' }]
}

onMounted(() => { getList() })

function getList() {
  loading.value = true
  listChannel(queryParams).then((res: any) => {
    list.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.id = undefined
  form.channelName = undefined
  form.channelType = undefined
  form.webhookUrl = undefined
  form.secret = undefined
  form.status = 1
  formRef.value?.resetFields()
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新增通知渠道'
}

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.id)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getChannel(id).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
    title.value = '修改通知渠道'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != undefined) {
        updateChannel({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addChannel({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleTest(row: any) {
  testChannel({
    channelType: row.channelType,
    webhookUrl: row.webhookUrl,
    secret: row.secret || ''
  }).then((res: any) => {
    if (res?.code === 200) {
      ElMessage.success('测试消息发送成功')
    } else {
      ElMessage.error(res?.msg || '发送失败')
    }
  }).catch(() => {
    ElMessage.error('网络错误')
  })
}

function handleDelete(row: any) {
  const idsArr = row.id || ids.value
  ElMessageBox.confirm('是否确认删除"' + (row.channelName || '') + '"？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delChannel(idsArr)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
