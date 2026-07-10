export function limitDecimalLength(value: number | string | null | undefined, decimalPlaces = 2): string {
  if (value === null || value === undefined || value === '') return ''
  let strValue = String(value)
  if (strValue === '') return ''
  if (strValue === '.') return '0.'
  const parts = strValue.split('.')
  if (parts.length > 2) strValue = parts[0] + '.' + parts.slice(1).join('')
  if (parts.length === 2 && parts[1].length > decimalPlaces) strValue = parseFloat(strValue).toFixed(decimalPlaces)
  return strValue
}

export function numberToString(value: number | null | undefined, decimalPlaces = 2): string {
  if (value === null || value === undefined) return ''
  return parseFloat(String(value)).toFixed(decimalPlaces)
}

export function stringToNumber(value: string | null | undefined): number {
  if (value === null || value === undefined || value === '') return 0
  return parseFloat(value) || 0
}
