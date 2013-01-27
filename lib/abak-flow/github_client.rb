# coding: utf-8
require "octokit"

module Abak::Flow
  module GithubClient

    def self.connection
      @@connection ||= Octokit::Client.new(params)
    end

    private
    def self.params
      Abak::Flow::Config.params
    end
  end
end