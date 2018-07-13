# frozen_string_literal: true
module ReviewBot
  class Notification
    def initialize(pull_request:, suggested_reviewers:)
      @pull_request = pull_request
      @suggested_reviewers = suggested_reviewers
    end

    attr_reader :pull_request, :suggested_reviewers

    def message
      [
        %(• ##{pull_request.number} <#{pull_request.html_url}|#{pull_request.title}> needs a review from),
        reviewers
      ].join(' ')
    end

    private

    def reviewers
      return '<!everyone>' if suggested_reviewers.empty?
      suggested_reviewers.map(&:slack_emoji).join(' ')
    end
  end
end
