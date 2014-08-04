# coding: utf-8
require "git"
require "octokit"
require "singleton"

module Abak::Flow
  class Manager
    include Singleton

    class << self
      def git
        instance.git
      end

      def github
        instance.github
      end

      def locale
        instance.locale
      end

      def configuration
        instance.configuration
      end

      def repository
        instance.repository
      end
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def repository
      @repository ||= Repository.new
    end

    def github
      @github ||= Octokit::Client.new(
        login: configuration.login,
        password: configuration.password,
        proxy: configuration.http_proxy)
    end

    def git
      @git ||= Git.open(".")
    end

    def locale
      @locale ||= Locale.new(configuration.locale)
    end
  end
end
