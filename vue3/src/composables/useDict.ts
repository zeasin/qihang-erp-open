import { ref, reactive, onMounted } from 'vue'
import { getDicts } from '@/api/system/dict/data'

const dictCache = new Map<string, any[]>()

export function useDict(...dictTypes: string[]) {
  const dict = reactive<Record<string, any[]>>({})

  onMounted(async () => {
    for (const type of dictTypes) {
      if (dictCache.has(type)) {
        dict[type] = dictCache.get(type)!
      } else {
        try {
          const res = await getDicts(type)
          const data = (res.data || []).map((item: any) => ({
            label: item.dictLabel,
            value: item.dictValue,
            ...item
          }))
          dictCache.set(type, data)
          dict[type] = data
        } catch {
          dict[type] = []
        }
      }
    }
  })

  return { dict }
}

export function clearDictCache() {
  dictCache.clear()
}
