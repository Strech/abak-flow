# coding: utf-8
#
# Wrapper class for git branches.
# Provides access to git branches and also defines current_branch
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
    class Branch
      attr_reader :git_branch
      
      PREFIX_HOTFIX = "hotfix"
      PREFIX_FEATURE = "feature"
      
      def initialize(branch)
        @git_branch = branch
      end
      
      def name
        git_branch.full
      end
      
      def prefix
      end
      
      def task
      end
      
      # methods:
      # => hotfix?
      # => feature?
      #
      #
      #
      
    end
  end
end