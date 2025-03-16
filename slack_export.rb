#!/usr/bin/env ruby

require 'dotenv/load'
require 'date'
require 'fileutils'
require 'active_support/time'
require_relative 'lib/slack_client'
require_relative 'lib/message_formatter'
require_relative 'lib/markdown_writer'

class SlackExporter
  def initialize(date = nil, output_dir = '.')
    @date = parse_date(date)
    @output_dir = output_dir
    validate_env_variables!
    @client = SlackClient.new
    @formatter = MessageFormatter.new(@client)
    @writer = MarkdownWriter.new(@date, @output_dir)
  end

  def export
    messages = @client.fetch_channel_messages(ENV['SLACK_CHANNEL_ID'], @date)
    formatted_messages = format_messages(messages)
    output_file = @writer.write(formatted_messages)
    puts "エクスポートが完了しました。出力ファイル: #{output_file}"
  end

  private

  def parse_date(date_str)
    return Date.today unless date_str

    Date.parse(date_str)
  rescue Date::Error
    puts '無効な日付形式です。YYYY-MM-DD形式で指定してください。'
    exit 1
  end

  def validate_env_variables!
    return if ENV['SLACK_BOT_TOKEN'] && ENV['SLACK_CHANNEL_ID']

    puts '環境変数 SLACK_BOT_TOKEN と SLACK_CHANNEL_ID が必要です。'
    puts '.env ファイルを確認してください。'
    exit 1
  end

  def format_messages(messages)
    formatted = []
    messages.reverse_each do |message|
      formatted << @formatter.format_message(message)
      formatted.concat(@formatter.format_thread(message, ENV['SLACK_CHANNEL_ID']))
    end
    formatted.compact
  end
end

if __FILE__ == $0
  begin
    date = ARGV[0]
    output_dir = ARGV[1] || '.'
    exporter = SlackExporter.new(date, output_dir)
    exporter.export
  rescue StandardError => e
    puts "エラーが発生しました: #{e.message}"
    puts "使用方法: #{$0} [YYYY-MM-DD] [出力先ディレクトリ]"
    exit 1
  end
end
