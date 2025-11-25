extends Node

const CONFIG_PATH := "user://app_config.json"

var data := {}      # 内存配置数据
var pretty := true  # 是否格式化输出 JSON

func _ready() -> void:
    data = FileUtil.load_json(CONFIG_PATH)

func save_config() -> void:
    var f := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
    if pretty:
        f.store_string(JSON.stringify(data, "  "))  # 缩进输出
    else:
        f.store_string(JSON.stringify(data))
    f.close()

func get_value(key: String, default_value = null):
    return data.get(key, default_value)

func set_value(key: String, value) -> void:
    data[key] = value
    save_config()

func delete_key(key: String) -> void:
    if data.has(key):
        data.erase(key)
        save_config()
