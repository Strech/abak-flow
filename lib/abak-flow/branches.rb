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
      ::Abak::Flow::Git.git
    end

  end
end