extends Node
class_name Douban

var http: HTTPRequest

func _ready():
    http = HTTPRequest.new()
    add_child(http)

func fetch_movie_from_douban_id(item: String) -> Dictionary:
    var url = "https://jasmine.pub:9980/api/movie/douban/%s" % item
    print(url)
    var err = http.request(url)
    if err != OK:
        return {}
    var result = await http.request_completed
    var status = result[1]
    if status != 200:
        return {}
    var json = JSON.new()
    var parse_error = json.parse(result[3].get_string_from_utf8())
    if parse_error != OK:
        return {}
    var response = json.get_data()
    if not response.get("success", false):
        return {}
    var data = response.get("data", {})
    data["douban"] = item
    return data


static func is_valid_douban_id(id_value: String) -> bool:
    var s := id_value.strip_edges()
    var regex := RegEx.new()
    regex.compile(r"^\d{6,10}$")
    return regex.search(s) != null
