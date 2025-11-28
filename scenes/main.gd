extends Control

@onready var container = $MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/GridContainer
var item_scene = preload("res://scenes/item.tscn")
var _items = [] # [{'path': path, 'meta': meta, 'instance': instance}]
const sort_options = [
    '默认排序',
    '按名称排序',
    '按年份排序',
    '按年份排序（倒序）',
]
var _sort_index = 0      # 排序选项
var _search_text = ''    # 搜索文本


func setup_ui() -> void:
    for option in sort_options:
        $MarginContainer/VBoxContainer/HBoxContainer/sort.add_item(option)
    $MarginContainer/VBoxContainer/HBoxContainer/sort.selected = 0


func _ready() -> void:
    setup_ui()
    load_items()
    display_items()


func load_items() -> void:
    _items.clear()

    var videos_path = Config.get_value('VIDEOS_PATH')
    print('videos_path: ', videos_path)
    if videos_path == null:
        $FileDialog.popup_centered()
        return

    var idx_file = FileUtil.join(videos_path, '.videos')
    if not FileAccess.file_exists(idx_file):
        print(idx_file, ' not exist')
        return

    var dirs = FileUtil.list_dirs(videos_path)
    for douban_id in dirs:
        if not Douban.is_valid_douban_id(douban_id):
            print('douban id: ', douban_id, ' not valid')
            continue
        var path = FileUtil.join(videos_path, douban_id)
        var meta_path = FileUtil.join(path, 'meta.json')
        var meta = {}
        if not FileAccess.file_exists(meta_path):
            print('meta file not exist: ', path)
        else:
            meta = FileUtil.load_json(meta_path)
        var douban_update_at = meta.get('douban_update_at')
        if douban_id and not douban_update_at:
            var douban := Douban.new()
            add_child(douban)
            var info = await douban.fetch_movie_from_douban_id(douban_id)
            meta.merge(info, true)
            meta.douban_update_at = Datetime.timestamp_now()
            FileUtil.save_json(meta_path, meta)
        _items.append({
            'path': path,
            'meta': meta
        })


func display_items() -> void:
    for child in container.get_children():
        child.queue_free()
    if _sort_index == 0:
        _items.sort_custom(func(a, b):
            return int(a['meta']["douban"]) < int(b['meta']["douban"])
        )
    elif _sort_index == 1:
        _items.sort_custom(func(a, b):
            return a['meta']["title"] < b['meta']["title"]
        )
    elif _sort_index == 2:
        _items.sort_custom(func(a, b):
            return a['meta']["year"] < b['meta']["year"]
        )
    elif _sort_index == 3:
        _items.sort_custom(func(a, b):
            return a['meta']["year"] > b['meta']["year"]
        )
    for item in _items:
        var meta = item['meta']
        if _search_text != '' and not meta['title'].containsn(_search_text):
            continue
        var instance = item_scene.instantiate()
        instance.data = meta
        instance.data.local_path = item['path']
        container.add_child(instance)
        item['instance'] = instance


func _on_settings_pressed() -> void:
    $FileDialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
    Config.set_value('VIDEOS_PATH', dir)
    load_items()
    display_items()


func _on_search_pressed() -> void:
    _search_text = $MarginContainer/VBoxContainer/HBoxContainer/search_text.text.strip_edges()
    display_items()


func _on_sort_item_selected(index: int) -> void:
    _sort_index = index
    display_items()
