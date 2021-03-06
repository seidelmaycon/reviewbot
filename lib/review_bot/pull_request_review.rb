module ReviewBot
  class PullRequestReview < Hashie::Mash
    def self.for_pull_request(pull_request)
      # github_api doesn't support this yet
      conn = Faraday.new(
        url: 'https://api.github.com',
        headers: { Accept: 'application/vnd.github.black-cat-preview+json' }
      )
      reviews_json = conn.get(
        "/repos/#{pull_request.repo_owner}/#{pull_request.repo_name}/pulls/#{pull_request.number}/reviews?access_token=#{ENV['GH_AUTH_TOKEN']}"
      ).body

      JSON.parse(reviews_json).map { |r| new r }
    end

    def approved?
      state == 'APPROVED'
    end

    def created_at
      submitted_at
    end
  end
end
