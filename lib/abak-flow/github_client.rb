# coding: utf-8
require "octokit"

module Abak::Flow
  module GithubClient

    def self.connection
      @@connection ||= Octokit::Client.new(params)
    end

    # TODO : Метод для получения SHA1 - пул реквест
    # def

    private
    def self.params
      Configuration.params
    end
  end
end