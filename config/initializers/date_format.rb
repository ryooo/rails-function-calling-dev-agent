date_format = {
  yyyymm: "%Y%m",
  yyyymmdd: "%Y%m%d",
  y_m_d: "%Y-%m-%d",
  jp_md: "%m月%d日",
  jp_ym: "%Y年%m月",
  jp_ymd: "%Y年%m月%d日",
  jp_mdw: ->(t) { t.strftime("%m月%d日(#{%w[日 月 火 水 木 金 土][t.wday]})") },
  jp_ymdw: ->(t) { t.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][t.wday]})") },
}
Date::DATE_FORMATS.merge!(date_format)
Time::DATE_FORMATS.merge!(date_format)

Time::DATE_FORMATS.merge!(
  hm: "%H:%M",
  file_name: "%Y_%m_%d_%H_%M_%S",
  jp_md_hm: "%m月%d日 %H:%M",
  jp_md_hms: "%m月%d日 %H:%M:%S",
  jp_ymd_hms: "%Y年%m月%d日 %H:%M:%S",
  jp_mdw_hm: ->(t) { t.strftime("%m月%d日(#{%w[日 月 火 水 木 金 土][t.wday]}) %H:%M") },
  jp_mdw_hms: ->(t) { t.strftime("%m月%d日(#{%w[日 月 火 水 木 金 土][t.wday]}) %H:%M:%S") },
  jp_ymdw_hms: ->(t) { t.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][t.wday]}) %H:%M:%S") }
)
Time::DATE_FORMATS.merge!(bigquery_format: "%Y-%m-%d %H:%M:%S%:z")

Time::DATE_FORMATS[:human] = lambda { |date|
  seconds = (Time.now - date).round
  days    = seconds / (60 * 60 * 24); return "#{days}日" if days > 1

  hours   = seconds / (60 * 60);      return "#{hours}時間" if hours.positive?

  minutes = seconds / 60;             return "#{minutes}分" if minutes.positive?

  return "#{seconds}秒"
}
