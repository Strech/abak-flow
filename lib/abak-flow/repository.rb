# coding: utf-8

module Abak::Flow
  class Repository
    extend Forwardable

    REMOTES = %w{origin upstream}.map(&:freeze)

    def initialize
      @_errors = Hash.new

      create_public_instance_methods
    end

    def valid?
      @_errors = Hash.new
      @_errors["origin"] = ['not_set'] if origin.nil?
      @_errors["upstream"] = ['not_set'] if upstream.nil?

      @_errors.empty?
    end

    def errors
      ErrorsPresenter.new(self, @_errors)
    end

    private

    def create_public_instance_methods
      remotes = Hash[fetch_remotes_from_git]

      REMOTES.each do |name|
        define_singleton_method(name) { remotes[name] }
      end
    end

    def fetch_remotes_from_git
      Manager.git.remotes.select { |remote| REMOTES.include?(remote.name) }
        .map { |remote| create_remote(remote) }.compact
    end

    def create_remote(remote)
      matches = /.+.github\.com[\:|\/](?<owner>.+)\/(?<project>.+).git/.match(remote.url)

      if !matches.nil? && matches.captures.length == 2
        [remote.name, Remote.new(matches[:owner], matches[:project], remote)]
      end
    end

    class Remote < Struct.new(:owner, :project, :repo)
      def to_s
        "#{owner}/#{project}"
      end
    end
  end
end
