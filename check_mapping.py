import json, re, sys

with open('menus.json', 'r', encoding='utf-8') as f:
    menus = json.load(f)

with open('vue3/src/store/modules/permission.ts', 'r', encoding='utf-8') as f:
    perm_ts = f.read()

matches = re.findall(r"'([^']+)':\s*\(\)\s*=>\s*import", perm_ts)
registered = set(matches)
# Also add entries with .vue suffix normalized
registered_norm = set()
for r in registered:
    registered_norm.add(r.replace('.vue', ''))

def collect_components(items):
    comps = set()
    if not items: return comps
    for item in items:
        comp = item.get('component', '')
        if comp and comp not in ('Layout', 'ParentView', '#'):
            comps.add(comp)
        if item.get('children'):
            comps.update(collect_components(item['children']))
    return comps

menu_comps = collect_components(menus.get('data', []))
print(f"菜单组件数: {len(menu_comps)}, viewsMap注册数: {len(registered)}")

missing = []
for comp in sorted(menu_comps):
    key = comp.replace('.vue', '')
    if key not in registered and key not in registered_norm:
        missing.append(comp)

if missing:
    print(f"\n缺少映射 ({len(missing)}):")
    for m in missing:
        print(f"  {m}")
else:
    print("\n所有组件均有映射")
