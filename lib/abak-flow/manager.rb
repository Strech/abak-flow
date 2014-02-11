# coding: utf-8
require "git"
require "octokit"
require "singleton"

module Abak::Flow
  class Manager
    include Singleton

    def initialize
      # preload dependencies
      configuration
      repository
    end

    def configuration
      @configuration ||= Configuration.new(self)
    end

    def repository
      @repository ||= Repository.new(self)
    end

    def github
      @github ||= Octokit::Client.new(login: configuration.oauth_user,
        oauth_token: configuration.oauth_token,
        proxy: configuration.http_proxy)
    end

    def git
      @git ||= Git.open(".")
    end

  end
end
