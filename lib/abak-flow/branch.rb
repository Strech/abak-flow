# coding: utf-8
#
# Wrapper class for git branch.
# Provides access to branch prefix and task name
# See Git::Branch
require "basic_decorator"

module Abak::Flow
  class Branch < ::BasicDecorator::Decorator
    PREFIX_HOTFIX = "hotfix"
    PREFIX_FEATURE = "feature"
    TASK_FORMAT = /^\w+\-\d{1,}$/
      
    def name
      @component.full
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
      
    private
    def split_prefix_and_task
      matches = name.match(/^(?<prefix>.+)\/(?<task>.+)$/)
        
      return [nil, nil] if matches.nil?
        
      [matches[:prefix], matches[:task]]
    end
      
  end
end