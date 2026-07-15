import json, os

vue2_views = set()
for root, dirs, files in os.walk('vue2/src/views'):
    for f in files:
        if f.endswith('.vue'):
            rel = os.path.relpath(os.path.join(root, f), 'vue2/src/views')
            vue2_views.add(rel.replace('\\', '/'))

vue3_views = set()
for root, dirs, files in os.walk('vue3/src/views'):
    for f in files:
        if f.endswith('.vue'):
            rel = os.path.relpath(os.path.join(root, f), 'vue3/src/views')
            vue3_views.add(rel.replace('\\', '/'))

exclude = {'system/dept/index.vue', 'system/post/index.vue', 'help/index.vue'}

missing = sorted(vue2_views - vue3_views - exclude)
print(f'Pages NOT yet migrated ({len(missing)}):')
for p in missing:
    print(f'  {p}')

print()
print('---')

# Also check from the menu data what visible menu items aren't migrated
with open('menus.json', 'r', encoding='utf-8') as f:
    menus = json.load(f)

def check_menu(items, depth=0):
    if not items:
        return
    for item in items:
        comp = item.get('component', '')
        hidden = item.get('hidden', False)
        title = item.get('meta', {}).get('title', '') if item.get('meta') else ''
        
        # Check if this component has a matching vue3 view
        if comp and comp not in ('Layout', 'ParentView'):
            view_path = comp
            if not view_path.endswith('.vue'):
                view_path = view_path + '.vue'
            
            # Check for index.vue variations
            vue3_path = view_path
            in_vue3 = vue3_path in vue3_views
            
            if not in_vue3:
                status = 'HIDDEN' if hidden else 'VISIBLE'
                print(f'  [{status}] title={title} comp={comp}')
        
        if item.get('children'):
            check_menu(item['children'], depth + 1)

print('Missing menu components:')
check_menu(menus.get('data', []))