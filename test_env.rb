#!/usr/bin/env ruby

require 'dotenv/load'

puts "SLACK_BOT_TOKEN: #{ENV['SLACK_BOT_TOKEN']}"
puts "SLACK_CHANNEL_ID: #{ENV['SLACK_CHANNEL_ID']}" 