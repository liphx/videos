extends Node
class_name Douban

var http: HTTPRequest

func _ready():
    http = HTTPRequest.new()
    add_child(http)


func fetch_movie_from_douban_id(item: String) -> Dictionary:
    var url = "https://movie.douban.com/subject/%s/" % item
    var headers = ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)"]

    var err = http.request(url, headers)
    if err != OK:
        return {}

    var result = await http.request_completed
    var status = result[1]
    var body = result[3].get_string_from_utf8()

    if status != 200:
        return {}

    # -----------------------
    # HTML 解析
    # -----------------------
    var title = extract_title(body)
    title = Common.html_unescape(title)
    var year = extract_year(body)
    var cover = extract_cover(body)
    var imdb = extract_imdb(body)

    return {
        "douban": item,
        "imdb": imdb,
        "title": title,
        "year": year,
        "cover": cover
    }


func extract_title(html: String) -> String:
    var regex := RegEx.new()
    regex.compile('<span.*?property="v:itemreviewed".*?>(.*?)</span>')
    var m := regex.search(html)
    if m:
        return m.get_string(1).strip_edges()
    return ""

func extract_year(html: String) -> int:
    var regex := RegEx.new()
    regex.compile('<span class="year">\\((\\d{4})\\)</span>')
    var m := regex.search(html)
    if m:
        return int(m.get_string(1))
    return 0



func extract_cover(html: String) -> String:
    var regex := RegEx.new()
    regex.compile('<img src="(https://img[0-9]+\\.doubanio\\.com/.*?)"')
    var m := regex.search(html)
    if m:
        return m.get_string(1)
    return ""


func extract_imdb(html: String) -> String:
    var regex := RegEx.new()
    var patterns := [
        # 精确匹配 <span class="pl">IMDb:</span> 后面的 tt 编号
        '<span[^>]*class=["\\\']pl["\\\'][^>]*>\\s*IMDb:\\s*</span>\\s*(tt\\d+)',
        # 任意位置出现 "IMDb: tt..." 的情况
        'IMDb:\\s*(tt\\d+)',
        # 最后回退：在页面中搜任何 tt 开头的编号（谨慎使用）
        '(tt\\d{5,})'
    ]
    for p in patterns:
        var err = regex.compile(p)
        if err != OK:
            continue
        var m := regex.search(html)
        if m:
            return m.get_string(1)
    return ""

static func is_valid_douban_id(id_value: String) -> bool:
    var s := id_value.strip_edges()
    var regex := RegEx.new()
    regex.compile(r"^\d{6,10}$")
    return regex.search(s) != null
