# frozen_string_literal: true
require 'pry-byebug'

module ReviewBot
  class Notification
    def initialize(pull_request:, suggested_reviewers:, notify_all:)
      @pull_request = pull_request
      @suggested_reviewers = suggested_reviewers
      @notify_all = notify_all
    end

    attr_reader :pull_request, :suggested_reviewers, :notify_all

    def message
      [
        %(• ##{pull_request.number} <#{pull_request.html_url}|#{pull_request.title}> #{pull_request_state}),
        reviewers
      ].join(' ')
    end

    def reviewers
      return '' unless notify_all
      suggested_reviewers.map(&:slack_emoji).join(' ')
    end

    private

    def pull_request_state
      return '' unless pull_request.ready_for_review?
      return 'needs a review from you.' unless notify_all
      'needs a review from '
    end
  end
end
