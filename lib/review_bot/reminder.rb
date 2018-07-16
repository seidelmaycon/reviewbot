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

    def notifications
      @notifications ||= potential_notifications.compact
    end

    def potential_notifications
      GH.pulls.list(owner, repo).body.map do |p|
        pull = PullRequest.new(p)

        print '.'

        next unless pull.needs_review?

        requested_reviewers = pull.requested_reviewers.map(&:login)

        reviewers_to_notify = app_reviewers
                              .select do |r|
                                requested_reviewers.include?(r.github)
                              end

        Notification.new(
          pull_request: pull,
          suggested_reviewers: reviewers_to_notify
        )
      end
    end
  end
end
