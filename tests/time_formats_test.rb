# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require_relative '../main'

class TimeFormatsTest < Minitest::Test
  def setup
    @old_tz = ENV['TZ']
    ENV['TZ'] = 'Asia/Shanghai'
    @now = Time.at(1_700_000_000)
  end

  def teardown
    ENV['TZ'] = @old_tz
  end

  def test_formats_share_the_same_instant
    result = QuickLauncherTimeFormats.response({ 'version' => 1 }, now: @now)
    assert_equal 1, result[:version]
    assert_equal 'list', result[:action]
    assert_equal ['06:13:20', '06:13', '06:13:20 AM', '2023-11-15T06:13:20+08:00', '1700000000',
                  '2023-11-15 06:13:20', '2023年11月15日 06时13分20秒', '20231115061320'],
                 result[:items].map { |item| item[:text] }
    assert_equal result[:items].map { |item| item[:text] }, result[:items].map { |item| item[:title] }
    assert result[:items].all? { |item| !item[:subtitle].empty? }
  end

  def test_uses_local_time_zone
    ENV['TZ'] = 'UTC'
    values = QuickLauncherTimeFormats.response({ 'version' => 1 }, now: @now)[:items].map { |item| item[:text] }
    assert_equal '22:13:20', values[0]
    assert_equal '2023-11-14T22:13:20+00:00', values[3]
    assert_equal '1700000000', values[4]
    assert_equal ['2023-11-14 22:13:20', '2023年11月14日 22时13分20秒', '20231114221320'], values[5, 3]
  end

  def test_full_date_time_formats_respect_leap_day_and_local_date_boundary
    instant = Time.utc(2024, 2, 29, 16, 5, 6)
    values = QuickLauncherTimeFormats.response({ 'version' => 1 }, now: instant)[:items].map { |item| item[:text] }
    assert_equal ['2024-03-01 00:05:06', '2024年03月01日 00时05分06秒', '20240301000506'], values[5, 3]

    ENV['TZ'] = 'UTC'
    values = QuickLauncherTimeFormats.response({ 'version' => 1 }, now: instant)[:items].map { |item| item[:text] }
    assert_equal ['2024-02-29 16:05:06', '2024年02月29日 16时05分06秒', '20240229160506'], values[5, 3]
  end

  def test_rejects_unsupported_request
    assert_equal 'error', QuickLauncherTimeFormats.response({ 'version' => 2 }, now: @now)[:action]
    assert_equal 'error', QuickLauncherTimeFormats.response(nil, now: @now)[:action]
  end

  def test_stdio_protocol_and_invalid_input
    executable = File.expand_path('../main.rb', __dir__)
    out, err, status = Open3.capture3('ruby', executable, stdin_data: '{"version":1}')
    assert status.success?
    assert_empty err
    result = JSON.parse(out)
    assert_equal 1, result.fetch('version')
    assert_equal 'list', result.fetch('action')
    assert_equal 8, result.fetch('items').size
    result.fetch('items').each do |item|
      %w[title subtitle text].each do |field|
        value = item.fetch(field)
        refute value.strip.empty?
        assert_operator value.length, :<=, 200
        refute_match(/[[:cntrl:]\u2028\u2029]/, value)
      end
    end
    out, _err, status = Open3.capture3('ruby', executable, stdin_data: '{')
    assert status.success?
    assert_equal 'error', JSON.parse(out).fetch('action')
  end
end
