extends Node

static func list_dirs(dir_path: String) -> Array:
    var result := []
    var dir := DirAccess.open(dir_path)
    if dir == null:
        return result

    dir.list_dir_begin()
    var name = dir.get_next()
    while name != "":
        if dir.current_is_dir() and not name.begins_with("."):
            result.append(name)
        name = dir.get_next()
    dir.list_dir_end()

    return result


static func _normalize_tokens(prefix: String, tokens: Array) -> String:
    var stack := []
    for t in tokens:
        if t == "" or t == ".":
            continue
        if t == "..":
            if stack.size() > 0:
                stack.pop_back()
            continue
        stack.append(t)

    return prefix + ("/".join(stack) if stack.size() > 0 else "")


static func join(first: String, ...rest) -> String:
    var parts: Array = [str(first)]
    for r in rest:
        parts.append(str(r))

    var scheme := ""
    var remainder_tokens := []

    if parts.size() > 0 and parts[0].begins_with("res://"):
        scheme = "res://"
        parts[0] = parts[0].substr(len(scheme))
    elif parts.size() > 0 and parts[0].begins_with("user://"):
        scheme = "user://"
        parts[0] = parts[0].substr(len(scheme))
    elif parts.size() > 0 and parts[0].begins_with("/"):   # 修正 starts_with → begins_with
        scheme = "/"
        parts[0] = parts[0].lstrip("/")

    for p in parts:
        var s := str(p).strip_edges()

        if s.begins_with("res://"):
            s = s.substr(len("res://"))
            if scheme == "":
                scheme = "res://"
        elif s.begins_with("user://"):
            s = s.substr(len("user://"))
            if scheme == "":
                scheme = "user://"

        for t in s.split("/"):
            remainder_tokens.append(t)

    var prefix := ""
    if scheme == "res://" or scheme == "user://":
        prefix = scheme
    elif scheme == "/":
        prefix = "/"

    var normalized := _normalize_tokens(prefix, remainder_tokens)

    if scheme == "/" and not normalized.begins_with("/"):
        normalized = "/" + normalized

    if normalized == "" and scheme != "":
        return scheme

    return normalized

static func load_json(file_path: String) -> Dictionary:
    if not FileAccess.file_exists(file_path):
        return {}

    var f := FileAccess.open(file_path, FileAccess.READ)
    if f == null:
        return {}

    var text := f.get_as_text()
    f.close()

    var result = JSON.parse_string(text)
    if typeof(result) == TYPE_DICTIONARY:
        return result
    return {}

static func save_json(path: String, data: Dictionary) -> bool:
    var file_or_err = FileAccess.open(path, FileAccess.WRITE)
    if not file_or_err is FileAccess:
        push_error("无法打开文件: %s" % path)
        return false

    var file: FileAccess = file_or_err
    var json_str = JSON.stringify(data, "\t")

    var ok = file.store_string(json_str)  # 返回 bool
    file.close()

    if not ok:
        push_error("写入文件失败: %s" % path)
        return false

    return true
