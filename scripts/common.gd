extends Node

func update_grid_columns(grid_container):
    if grid_container == null or grid_container.get_child_count() == 0:
        return
    var container_width = grid_container.get_parent().size.x
    var item_width = grid_container.get_child(0).size.x
    var columns = int(container_width / item_width)
    grid_container.columns = max(columns, 1) # 至少 1 列

static func html_unescape(text: String) -> String:
    return text.replace("&#39;", "'").replace("&quot;", "\"").replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
