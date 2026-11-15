#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

module QuickLauncherTimeFormats
  def self.response(request, now: Time.now)
    return { version: 1, action: 'error', text: '不支持的请求版本。' } unless request.is_a?(Hash) && request['version'] == 1

    local = now.getlocal
    formats = [
      ['time_24h_seconds', '24 小时制 · HH:mm:ss', local.strftime('%H:%M:%S')],
      ['time_24h_minutes', '24 小时制 · HH:mm', local.strftime('%H:%M')],
      ['time_12h_seconds', '12 小时制', local.strftime('%I:%M:%S %p')],
      ['iso8601_offset', 'ISO 8601 · 带时区', local.strftime('%Y-%m-%dT%H:%M:%S%:z')],
      ['unix_seconds', 'Unix 时间戳 · 秒', now.to_i.to_s],
      ['datetime_hyphen', '日期时间 · yyyy-MM-dd HH:mm:ss', local.strftime('%Y-%m-%d %H:%M:%S')],
      ['datetime_chinese', '完整中文日期时间', local.strftime('%Y年%m月%d日 %H时%M分%S秒')],
      ['datetime_compact', '紧凑日期时间 · yyyyMMddHHmmss', local.strftime('%Y%m%d%H%M%S')]
    ]
    items = formats.map { |id, label, value| { id: id, title: value, subtitle: label, text: value } }
    { version: 1, action: 'list', items: items }
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    request = JSON.parse(STDIN.read)
    result = QuickLauncherTimeFormats.response(request)
  rescue JSON::ParserError
    result = { version: 1, action: 'error', text: '请求格式无效。' }
  end
  puts JSON.generate(result)
end
