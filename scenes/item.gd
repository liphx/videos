extends Control

var data = {
    "title": "还有明天 C'è ancora domani",
    "year": 2023,
    "douban": "36445098",
    "imdb": "tt21800162",
    "cover": "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2918279456.jpg",
    "local_path": "E:/Videos/DATA/1"
}

func _ready() -> void:
    #print(data)
    if data == null:
        return
    var vbox = $MarginContainer/VBoxContainer
    vbox.mouse_filter = Control.MOUSE_FILTER_STOP
    vbox.connect("gui_input", Callable(self, "_on_vbox_input"))

    # 标题
    $MarginContainer/VBoxContainer/title.text = "{0} ({1})".format([data.title, int(data.year)])

    # 本地封面路径
    var local_cover_path := FileUtil.join(data.local_path, "cover.jpg")
    var load_cover_from_local = false
    # 1) 本地已有封面 → 直接加载
    if FileAccess.file_exists(local_cover_path):
        var img := Image.new()
        var err := img.load(local_cover_path)
        if err == OK:
            var tex := ImageTexture.create_from_image(img)
            $MarginContainer/VBoxContainer/cover.texture = tex
            load_cover_from_local = true
            return
        # 本地文件损坏则继续尝试网络下载
    # 2) 网络下载封面 → 显示 → 保存到本地
    if not load_cover_from_local and data.cover:
        print('download: ', data.cover)
        var http := HTTPRequest.new()
        add_child(http)

        var err := http.request(data.cover)
        if err != OK:
            return

        var result = await http.request_completed
        var status = result[1]
        var body = result[3]

        if status != 200:
            return

        # 加载图片（PNG 或 JPG）
        var img := Image.new()
        var load_err := img.load_png_from_buffer(body)
        if load_err != OK:
            load_err = img.load_jpg_from_buffer(body)
            if load_err != OK:
                return

        # 设置封面纹理
        var tex := ImageTexture.create_from_image(img)
        $MarginContainer/VBoxContainer/cover.texture = tex

        # 保存到本地
        _save_cover_to_local(local_cover_path, img)


func _save_cover_to_local(path: String, image: Image) -> void:
    # 保存目录不存在时创建
    var dir_path := path.get_base_dir()
    DirAccess.make_dir_recursive_absolute(dir_path)

    var img_format := "jpg"  # 统一保存为 JPG

    # 将 Image 编码为 JPG buffer
    var buf := image.save_jpg_to_buffer()
    if buf == null:
        return

    var f := FileAccess.open(path, FileAccess.WRITE)
    if f == null:
        return
    f.store_buffer(buf)
    f.close()


func _on_vbox_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        print("VBoxContainer clicked!")
        if data.local_path and DirAccess.dir_exists_absolute(data.local_path):
            OS.shell_open(data.local_path)
        else:
            print("路径不存在:", data.local_path)
