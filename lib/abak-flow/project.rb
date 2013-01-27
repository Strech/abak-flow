# coding: utf-8
#
# Module for access to github repos owner and project names
# recieved from .git repo
module Abak::Flow
  module Project
    def self.init
      init_remotes
    end

    def self.remotes
      @@remotes.dup
    end

    protected
    def self.init_remotes
      @@remotes = Hash[fetch_remotes_from_git]
    end

    def self.required_remote_names
      [:origin, :upstream]
    end

    def self.git
      Git.git
    end

    def self.check_requirements
      if remotes.length != 2
        raise Exception, "You have incorrect github remotes. Check your git config"
      end
    end

    def self.fetch_remotes_from_git
      git.remotes.
          select { |remote| required_remote_names.include? remote.name.to_sym }.
          map { |remote| create_github_remote remote }.
          compact
    end

    def self.create_github_remote(remote)
      matches = /.+.github\.com[\:|\/](?<owner>.+)\/(?<project>.+).git/.match(remote.url)

      if !matches.nil? && matches.captures.length == 2
        [remote.name.to_sym, Remote.new(matches[:owner], matches[:project])]
      end
    end

    class Remote < Struct.new(:owner, :project)
      def to_s
        "#{owner}/#{project}"
      end
    end

    required_remote_names.each do |name|
      self.class.send :define_method, name, -> { remotes[name] }
    end

  end
end