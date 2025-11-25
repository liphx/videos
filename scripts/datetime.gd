extends Node


# 获取当前时间戳（秒）
func timestamp_now() -> int:
    var utc_timestamp = Time.get_unix_time_from_system()
    var timezone_offset = Time.get_time_zone_from_system().bias * 60  # 获取本地时区偏移（秒）
    return utc_timestamp + timezone_offset
