require 'time'
require 'active_support/time'

class MessageFormatter
  def initialize(slack_client)
    @slack_client = slack_client
    @user_cache = {}
  end

  def format_message(message, indent_level = 0)
    return nil unless message['text']

    timestamp = Time.at(message['ts'].to_f).in_time_zone('Asia/Tokyo')
    user_info = get_user_info(message['user'])
    username = user_info&.profile&.display_name || user_info&.name || 'Unknown User'

    message_link = create_message_link(message['ts'])
    text = format_text(message['text'], indent_level)

    indent = '  ' * indent_level
    "#{indent}* [#{timestamp.strftime('%Y-%m-%d %H:%M:%S')}](#{message_link}) @#{username} : #{text}"
  end

  def format_thread(parent_message, channel_id)
    return [] unless parent_message['thread_ts']
    return [] if parent_message['thread_ts'] != parent_message['ts'] # 親メッセージでない場合はスキップ

    replies = @slack_client.fetch_thread_replies(channel_id, parent_message['thread_ts'])
    replies.map { |reply| format_message(reply, 1) }.compact
  end

  private

  def get_user_info(user_id)
    return nil unless user_id

    @user_cache[user_id] ||= @slack_client.fetch_user_info(user_id)
  end

  def create_message_link(ts)
    "https://slack.com/archives/#{ENV['SLACK_CHANNEL_ID']}/p#{ts.gsub('.', '')}"
  end

  def format_text(text, indent_level = 0)
    # URLを保持
    text = text.gsub(/<(http[^>|]+)>/, '\1')
    # URLWithTextを保持
    text = text.gsub(/<(http[^>|]+)\|([^>]+)>/, '[\2](\1)')
    # メンションを@usernameの形式に変換
    text = text.gsub(/<@([^>]+)>/) do
      user_info = get_user_info($1)
      "@#{user_info&.name || $1}"
    end

    # テキストをコードブロックとそれ以外に分割して処理
    parts = text.split(/(```.*?```)/m)
    formatted_parts = parts.map.with_index do |part, i|
      if i.odd? # コードブロック
        content = part.match(/```(.*?)```/m)[1].strip
        "\n```\n#{content}\n```\n"
      else # 通常のテキスト
        part.gsub(/\n/, "<BR>\n#{' ' * indent_level}")
      end
    end

    # インラインコードを保持
    text = formatted_parts.join
    text = text.gsub(/`([^`]+)`/, '`\1`')
    # 末尾の余分な改行を削除
    text.rstrip
  end
end
