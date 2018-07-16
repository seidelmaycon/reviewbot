# frozen_string_literal: true
require 'slack'
require 'json'
require 'dotenv'
require_relative 'lib/review_bot'
Dotenv.load

CONFIG = JSON.parse ENV['CONFIG']
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

desc 'Send reminders to team members to review PRs'
task :remind, [:mode] do |_t, args|
  dry_run = args[:mode] == 'dry'

  puts "-- DRY RUN --\n\n" if dry_run

  CONFIG.each do |app, app_config|
    owner, repo = app.split('/')
    room = app_config['room']

    puts "#{owner}/#{repo}"

    ReviewBot::HourOfDay.work_days = app_config['work_days']

    message = ReviewBot::Reminder.new(owner, repo, app_config).message

    next if message.nil?

    client = Slack::Web::Client.new
    client.chat_postMessage(channel: room, text: message, as_user: true)
  end
end
