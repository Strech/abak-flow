# coding: utf-8
require "i18n"
require "ruler"
require "forwardable"

module Abak::Flow
  class Repository
    include Ruler
    extend Forwardable

    REMOTES = [:origin, :upstream].freeze

    def_delegators :@manager, :git

    attr_reader :errors

    def initialize(manager)
      @manager = manager
      @errors  = []

      configure!
    end

    def ready?
      @errors = []

      multi_ruleset do
        fact(:origin_not_setup) { origin.nil? }
        fact(:upstream_not_setup) { upstream.nil? }

        rule([:origin_not_setup]) { @errors << I18n.t("repository.errors.origin_not_setup") }
        rule([:upstream_not_setup]) { @errors << I18n.t("repository.errors.upstream_not_setup") }
      end

      @errors.empty? ? true : false
    end

    def display_name
      I18n.t("repository.name")
    end

    private
    def configure!
      remotes = Hash[fetch_remotes_from_git]
      REMOTES.each do |name|
        define_singleton_method(name) { remotes[name] }
      end
    end

    def fetch_remotes_from_git
      git.remotes.
          select { |remote| REMOTES.include?(remote.name.to_sym) }.
          map { |remote| create_remote(remote) }.
          compact
    end

    def create_remote(remote)
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
