export function parseTime(time: string | number | Date | undefined | null, pattern?: string): string {
  if (!time) return ''
  const format = pattern || '{y}-{m}-{d} {h}:{i}:{s}'
  let date: Date
  if (typeof time === 'object') {
    date = time as Date
  } else {
    if (typeof time === 'string' && /^[0-9]+$/.test(time)) {
      time = parseInt(time)
    } else if (typeof time === 'string') {
      time = time.replace(/-/gm, '/').replace('T', ' ').replace(/\.[\d]{3}/gm, '')
    }
    if (typeof time === 'number' && time.toString().length === 10) {
      time = time * 1000
    }
    date = new Date(time)
  }
  const formatObj: Record<string, number> = {
    y: date.getFullYear(),
    m: date.getMonth() + 1,
    d: date.getDate(),
    h: date.getHours(),
    i: date.getMinutes(),
    s: date.getSeconds(),
    a: date.getDay()
  }
  return format.replace(/{(y|m|d|h|i|s|a)+}/g, (result, key: string) => {
    let value = formatObj[key]
    if (key === 'a') return ['日', '一', '二', '三', '四', '五', '六'][value]
    if (result.length > 0 && value < 10) {
      value = Number('0' + value)
    }
    return String(value || 0)
  })
}

export function addDateRange(params: Record<string, any>, dateRange: string[], propName?: string) {
  const search = params
  search.params = typeof search.params === 'object' && search.params !== null && !Array.isArray(search.params) ? search.params : {}
  dateRange = Array.isArray(dateRange) ? dateRange : []
  if (typeof propName === 'undefined') {
    search.params['beginTime'] = dateRange[0]
    search.params['endTime'] = dateRange[1]
  } else {
    search.params['begin' + propName] = dateRange[0]
    search.params['end' + propName] = dateRange[1]
  }
  return search
}

export function handleTree(data: any[], id?: string, parentId?: string, children?: string) {
  const config = {
    id: id || 'id',
    parentId: parentId || 'parentId',
    childrenList: children || 'children'
  }
  const childrenListMap: Record<string, any[]> = {}
  const nodeIds: Record<string, any> = {}
  const tree: any[] = []
  for (const d of data) {
    const pid = d[config.parentId]
    if (!childrenListMap[pid]) {
      childrenListMap[pid] = []
    }
    nodeIds[d[config.id]] = d
    childrenListMap[pid].push(d)
  }
  for (const d of data) {
    const pid = d[config.parentId]
    if (!nodeIds[pid]) {
      tree.push(d)
    }
  }
  for (const t of tree) {
    adaptToChildrenList(t)
  }
  function adaptToChildrenList(o: any) {
    if (childrenListMap[o[config.id]] !== null) {
      o[config.childrenList] = childrenListMap[o[config.id]]
    }
    if (o[config.childrenList]) {
      for (const c of o[config.childrenList]) {
        adaptToChildrenList(c)
      }
    }
  }
  return tree
}

export function selectDictLabel(datas: any[], value: any): string {
  if (value === undefined || value === null) return ''
  const actions: string[] = []
  datas.some((data: any) => {
    if (data.value === String(value)) {
      actions.push(data.label)
      return true
    }
    return false
  })
  return actions.length ? actions.join('') : String(value)
}

export function parseStrEmpty(str: any): string {
  if (!str || str === 'undefined' || str === 'null') return ''
  return str
}

export function amountFormatter(value: number | string | null | undefined): string {
  if (value === null || value === undefined) return ''
  const num = typeof value === 'string' ? parseFloat(value) : value
  return '¥' + num.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}
