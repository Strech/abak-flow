# coding: utf-8

module Abak::Flow
  class Branch
    PREFIX_HOTFIX  = "hotfix".freeze
    PREFIX_FEATURE = "feature".freeze
    TASK_FORMAT    = /^\w+\-\d{1,}$/.freeze

    DEVELOPMENT = "develop".freeze
    MASTER      = "master".freeze

    # def compare_link
    # File.join [
    #   m.github.web_endpoint,
    #   m.repository.origin.to_s,
    #   "compare",
    #   "#{m.repository.upstream.owner}:#{base}...#{head}",
    # ] 
    # end

    # def current?
    # ...
    # end

    # def update
    # ...
    # end

    def initialize(branch, manager)
      @manager = manager
      @branch = branch.is_a?(Git::Branch) ? branch : manager.git.branch(name)
    end

    def name
      @branch.full
    end

    def folder
      split_prefix_and_task.first
    end

    def task
      split_prefix_and_task.last
    end

    def hotfix?
      prefix == PREFIX_HOTFIX
    end

    def feature?
      prefix == PREFIX_FEATURE
    end

    def tracker_task?
      !(task =~ TASK_FORMAT).nil?
    end

    def mappable?
      hotfix? || feature?
    end

    private
    def split_prefix_and_task
      return @folder_and_task if defined? @folder_and_task

      matches = name.match(/^(?<prefix>.+)\/(?<task>.+)$/)

      @folder_and_task = matches.nil? ? [nil, nil]
                                      : [matches[:prefix], matches[:task]]
    end
  end
end
