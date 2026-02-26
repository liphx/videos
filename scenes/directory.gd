extends Window

@onready var container = $MarginContainer/VBoxContainer
var paths = []

func _ready() -> void:
    refresh()


func refresh():
    for i in container.get_children():
        i.queue_free()
    paths = Config.get_value("VIDEOS_PATHS", [])
    for path in paths:
        var hbox = HBoxContainer.new()
        container.add_child(hbox)

        var label = Label.new()
        label.text = path
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(label)

        var btn = Button.new()
        btn.icon = load("res://assets/images/close.svg")
        btn.expand_icon = true
        btn.custom_minimum_size = Vector2(30, 30)
        btn.pressed.connect(remove_path.bind(path))
        hbox.add_child(btn)

    var btn = Button.new()
    btn.text = '添加目录'
    btn.pressed.connect(open_file_dialog)
    container.add_child(btn)


func remove_path(path):
    paths.erase(path)
    Config.set_value('VIDEOS_PATHS', paths)
    refresh()


func open_file_dialog():
    $FileDialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
    paths.append(dir)
    Config.set_value('VIDEOS_PATHS', paths)
    refresh()


func _on_close_requested() -> void:
    queue_free()
