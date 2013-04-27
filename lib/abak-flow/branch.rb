# coding: utf-8
#
# Wrapper class for git branch.
# Provides access to branch prefix and task name
# See Git::Branch
require "delegate"

module Abak::Flow
  class Branch < SimpleDelegator
    PREFIX_HOTFIX  = "hotfix".freeze
    PREFIX_FEATURE = "feature".freeze
    TASK_FORMAT    = /^\w+\-\d{1,}$/.freeze

    DEVELOPMENT = "develop".freeze
    MASTER      = "master".freeze

    def name
      __getobj__.full
    end

    def prefix
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

    def task?
      !(task =~ TASK_FORMAT).nil?
    end

    def tracker_task
      return nil unless task?

      task
    end

    private
    def split_prefix_and_task
      return @prefix_and_task if defined? @prefix_and_task

      matches = name.match(/^(?<prefix>.+)\/(?<task>.+)$/)

      @prefix_and_task = matches.nil? ? [nil, nil]
                                      : [matches[:prefix], matches[:task]]
    end
  end
end