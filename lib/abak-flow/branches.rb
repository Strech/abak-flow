# coding: utf-8
#
# Wrapper class for git branches.
# Provides access to git branches and also defines current_branch
module Abak::Flow
  module Branches
    extend Forwardable

    def_delegator "Git.instance", :git

    def self.current_branch
      Branch.new git.branches[git.current_branch]
    end

    # ==========================================================================
    # TODO : Refactor
    # 3. Statistics & Cleaning
    #
    # => PullRequest.garbage
    # => PullRequest.clean
    # => PullRequest.clean(hard: true)
    def self.garbage
      Project.init
      [Project.upstream.repo, Project.origin.repo].map(&:fetch)

      branches = GithubClient.connection.branches(Project.origin.to_s)
                             .reject { |branch| %w(master develop).include? branch.name }

      messages = Messages.new "pull_request.garbage"
      messages << [:collected_branches, {count: branches.count}]

      branches.each_with_index do |branch, index|

        # WRONG PREFIX
        upstream_branch = Git.command_lines("branch", ["-r", "--contain", branch.commit.sha])
                             .select { |branches| branches.include? "upstream/#{branch.prefix}" }

        local_sha = git.branches[branch.name] ? git.branches[branch.name].gcommit.sha : ""

        statuses = {
          branch_unused: upstream_branch.empty?,
          branch_differ: !local_sha.empty? && local_sha != branch.commit.sha,
          branch_missing: local_sha.empty?
        }

        unless statuses.values.inject &:|
          messages << [:deletion_allowed, {index: index, branch_name: branch.name}]
          next
        end

        diagnoses = statuses.select { |_, bool| bool }.
                             map { |name, _| messages.t name }.
                             map { |msg| "   ↪ #{msg}" }.
                             join("\n")

        if statuses.select { |_, bool| bool }.keys == [:missing]
          messages << [:deletion_possibly, {index: index, branch_name: branch.name, diagnoses: diagnoses}]
        else
          messages << [:deletion_restricted, {index: index, branch_name: branch.name, diagnoses: diagnoses}]
        end
      end

      messages
    end


  end
end