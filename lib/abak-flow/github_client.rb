# -*- encoding: utf-8 -*-
module Abak::Flow
  class GithubClient
    def self.connect(config)
      return @github_connect unless @github_connect.nil?

      github_options = {:login => config.api_user, :oauth_token => config.api_token}
      github_options[:proxy] = config.proxy if config.proxy?

      @github_connect = Octokit::Client.new(github_options)
    end
  end
end