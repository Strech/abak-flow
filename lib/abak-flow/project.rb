# coding: utf-8
# FIXME : Гем гит на каждый апстрим читает конфиг файл, это ПИЗДЕЦ
#
# Module for access to github repos owner and project names
# recieved from .git repo
require "singleton"
require "forwardable"

module Abak::Flow
  class Project
    include Singleton
    extend Forwardable

    REQUIRED_REMOTES_NAMES = [:origin, :upstream].freeze

    def_delegator "Abak::Flow::Git.instance", :git

    attr_reader :remotes

    def initialize
      initialize_remotes
    end

    private
    def initialize_remotes
      @remotes = Hash[fetch_remotes_from_git]
    end

    def fetch_remotes_from_git
      git.remotes.
          select { |remote| REQUIRED_REMOTES_NAMES.include? remote.name.to_sym }.
          map { |remote| create_github_remote remote }.
          compact
    end

    def create_github_remote(remote)
      matches = /.+.github\.com[\:|\/](?<owner>.+)\/(?<project>.+).git/.match(remote.url)

      if !matches.nil? && matches.captures.length == 2
        [remote.name.to_sym, Remote.new(matches[:owner], matches[:project], remote)]
      end
    end

    class Remote < Struct.new(:owner, :project, :repo)
      def to_s
        "#{owner}/#{project}"
      end
    end
  end
end