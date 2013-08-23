# coding: utf-8
require "git"

module Abak::Flow
  class Manager

    def initialize
      # preload dependencies
      configuration
      repository

      yield self if block_given?
    end

    def configuration
      @configuration ||= Configuration.new(self)
    end

    def repository
      @repository ||= Repository.new(self)
    end

    def git
      @git ||= Git.open(".")
    end

  end
end
