require 'slack-ruby-client'
require 'time'

class SlackClient
  def initialize(token = ENV['SLACK_BOT_TOKEN'])
    Slack.configure do |config|
      config.token = token
    end
    @client = Slack::Web::Client.new
    @rate_limit_retries = 3
  end

  def fetch_channel_messages(channel_id, date)
    start_time = date.to_time.beginning_of_day
    end_time = date.to_time.end_of_day

    with_rate_limit do
      @client.conversations_history(
        channel: channel_id,
        oldest: start_time.to_i.to_s,
        latest: end_time.to_i.to_s,
        limit: 1000
      ).messages
    end
  end

  def fetch_thread_replies(channel_id, thread_ts)
    with_rate_limit do
      @client.conversations_replies(
        channel: channel_id,
        ts: thread_ts
      ).messages[1..-1] # 最初のメッセージは親なので除外
    end
  end

  def fetch_user_info(user_id)
    with_rate_limit do
      @client.users_info(user: user_id).user
    end
  end

  private

  def with_rate_limit
    retries = 0
    begin
      yield
    rescue Slack::Web::Api::Errors::TooManyRequestsError => e
      raise if retries >= @rate_limit_retries

      sleep(e.retry_after)
      retries += 1
      retry
    end
  end
end
