#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

module QuickLauncherTimeFormats
  def self.response(request, now: Time.now)
    return { version: 1, action: 'error', text: '不支持的请求版本。' } unless request.is_a?(Hash) && request['version'] == 1

    local = now.getlocal
    formats = [
      ['24 小时制 · HH:mm:ss', local.strftime('%H:%M:%S')],
      ['24 小时制 · HH:mm', local.strftime('%H:%M')],
      ['12 小时制', local.strftime('%I:%M:%S %p')],
      ['ISO 8601 · 带时区', local.strftime('%Y-%m-%dT%H:%M:%S%:z')],
      ['Unix 时间戳 · 秒', now.to_i.to_s]
    ]
    items = formats.map { |label, value| { title: value, subtitle: label, text: value } }
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
