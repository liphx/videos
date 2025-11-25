extends Control

var item_scene = preload("res://scenes/item.tscn")
@onready var container = $MarginContainer/ScrollContainer/CenterContainer/GridContainer

func _ready() -> void:
    Config.set_value('VIDEOS_PATH', 'E:/Videos')
    var videos_path = Config.get_value('VIDEOS_PATH')
    print('videos_path: ', videos_path)

    var dirs = FileUtil.list_dirs(videos_path)
    for dir in dirs:
        var path = FileUtil.join(videos_path, dir)
        #print(path)
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
