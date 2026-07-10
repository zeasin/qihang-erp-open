import { ref, onMounted } from 'vue'
import { getDicts } from '@/api/system/dict/data'

const dictCache = new Map<string, any[]>()

export function useDict(...dictTypes: string[]) {
  const dict = ref<Record<string, any[]>>({})

  onMounted(async () => {
    for (const type of dictTypes) {
      if (dictCache.has(type)) {
        dict.value[type] = dictCache.get(type)!
      } else {
        try {
          const res = await getDicts(type)
          const data = res.data || []
          dictCache.set(type, data)
          dict.value[type] = data
        } catch {
          dict.value[type] = []
        }
      }
    }
  })

  return { dict }
}

export function clearDictCache() {
  dictCache.clear()
}
