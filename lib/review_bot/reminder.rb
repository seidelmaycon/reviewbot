# frozen_string_literal: true
module ReviewBot
  GH = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])

  class Reminder
    attr_reader :owner, :repo, :app_config

    def initialize(owner, repo, app_config)
      @owner = owner
      @repo = repo
      @app_config = app_config
    end

    def message
      return if notifications.empty?
      notifications.map(&:message).join("\n")
    end

    def app_reviewers
      @app_reviewers ||= app_config['reviewers'].map { |r| Reviewer.new(r) }
    end

    def out_reviewers
      return @out_reviewers if defined?(@out_reviewers)
      return @out_reviewers = [] unless bamboo_hr

      @out_reviewers ||=
        begin
          whos_out_ids = bamboo_hr
                         .whos_out(start_date: Date.today)
                         .map { |t| t['employeeId'] }
          app_reviewers.select { |r| whos_out_ids.include? r.bamboohr }
        end
    end

    def bamboo_hr
      return @bamboo_hr if defined?(@bamboo_hr)

      @bamboo_hr ||=
        if app_config['bamboohr_subdomain']
          BambooHR.new(
            api_key: ENV['BAMBOOHR_API_KEY'],
            subdomain: app_config['bamboohr_subdomain']
          )
        end
    end

    def notifications
      @notifications ||= potential_notifications.compact
    end

    def potential_notifications
      GH.pulls.list(owner, repo).body.map do |p|
        pull = PullRequest.new(p)

        print '.'

        next unless pull.needs_review?

        Notification.new(
          pull_request: pull,
          suggested_reviewers: pull.reviewers
        )
      end
    end
  end
end
