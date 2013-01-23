# coding: utf-8
#
# Wrapper class for git branches.
# Provides access to git branches and also defines current_branch
require "basic_decorator"

module Abak::Flow
  module Branches
    
    def self.current_branch
      Branch.new git.branches[git.current_branch]
    end
    
    def self.git
      Git.git
    end

    # Wrapper class for git branch.
    # Provides access to branch prefix and task name
    # See Git::Branch
    class Branch < ::BasicDecorator::Decorator
      PREFIX_HOTFIX = "hotfix"
      PREFIX_FEATURE = "feature"
      TASK_FORMAT = //
      
      def name
        @component.full
      end
      
      def prefix
        "???"
      end
      
      def task
        "???"
      end
      
      def hotfix?
      end
      
      def feature?
      end
      
      def task?
      end
      
    end
  end
end