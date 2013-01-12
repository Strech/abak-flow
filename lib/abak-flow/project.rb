# coding: utf-8
#
# Module for access to github repos owner and project names
# recieved from .git repo
module Abak::Flow
  module Project

    def self.init
      init_remotes
    end

    def self.init_remotes
      git.remotes.each do |remote|
        self.class.send :define_method, remote.name, generate_proc(remote)
      end
    end

    private
    def self.git
      Git.open('.')
    end

    def self.generate_proc(remote)
      matches = /.+.github\.com\:(?<owner>.+)\/(?<project>.+).git/.match(remote.url)

      if matches.nil? || matches.captures.length != 2
        raise Exception, "You have incorrect github remotes. Check your git config"
      end

      -> { Remote.new(matches[:owner], matches[:project]) }
    end

    class Remote < Struct.new(:owner, :project)
      def to_s
        "#{owner}/#{project}"
      end
    end

  end
end