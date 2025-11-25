extends Control

var item_scene = preload("res://scenes/item.tscn")
@onready var container = $MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/GridContainer

var _items = {}

func _ready() -> void:
    load_items()


func load_items() -> void:
    _items.clear()
    for child in container.get_children():
        child.queue_free()

    var videos_path = Config.get_value('VIDEOS_PATH')
    print('videos_path: ', videos_path)
    if videos_path == null:
        $FileDialog.popup_centered()
        return

    var dirs = FileUtil.list_dirs(videos_path)
    for dir in dirs:
        var path = FileUtil.join(videos_path, dir)
        var meta_path = FileUtil.join(path, 'meta.json')
        if not FileAccess.file_exists(meta_path):
            print(path)
            continue
        var meta = FileUtil.load_json(meta_path)
        var douban_id = meta.get('douban')
        var douban_update_at = meta.get('douban_update_at')
        if douban_id and not douban_update_at:
            var douban := Douban.new()
            add_child(douban)
            var info = await douban.fetch_movie_from_douban_id(douban_id)
            meta.merge(info, true)
            meta.douban_update_at = Datetime.timestamp_now()
            FileUtil.save_json(meta_path, meta)
        var instance = item_scene.instantiate()
        instance.data = meta
        instance.data.local_path = path
        container.add_child(instance)
        _items[path] = meta
        _items[path]['instance'] = instance


func _on_settings_pressed() -> void:
    $FileDialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
    Config.set_value('VIDEOS_PATH', dir)
    load_items()


func _on_search_pressed() -> void:
    var text = $MarginContainer/VBoxContainer/HBoxContainer/search_text.text.strip_edges()
    print('search_text: ', text)
    if text == '': # 重置
        for path in _items:
            var instance = _items[path]['instance']
            instance.show()
        return
    for path in _items:
        var instance = _items[path]['instance']
        instance.hide()
        if _items[path]['title'].containsn(text):
            instance.show()
