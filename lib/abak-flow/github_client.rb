# coding: utf-8
require "octokit"

module Abak::Flow
  module GithubClient

    # TODO : Переделать на синглтон
    def self.connection
      @@connection ||= Octokit::Client.new(Configuration.instance.params)
    end

    # TODO : Метод для получения SHA1 - пул реквест
    # def
  end
end