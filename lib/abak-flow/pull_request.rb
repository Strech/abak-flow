# coding: utf-8
#
# Class for pushing/updating/checking pull requests
require "ruler"

module Abak::Flow
  class PullRequest
    include Ruler
    extend Forwardable

    attr_reader :options, :github_link, :exception
    attr_reader :recommendations

    BRANCH_MAPPING = {feature: "develop", hotfix: "master"}.freeze

    # New pull request
    #
    # options - Hash with options
    #           branch  - target branch name
    #           title   - pull request title
    #           comment - pull request additional comment
    #
    # Examples
    #   pr = PullRequest.new(*attrs)
    #   pr.valid?   # =>  state.valid?
    #   pr.invalid? # =>  state.invalid?
    #   pr.recommendations # => ["one", "two", "three"]
    #
    # Rerurns nil
    def initialize(options = {})
      @options = options
      @recommendations = Messages.new "pull_request.recommendations"
    end

    def valid?
      return false unless System.instance.ready?

      requirements_satisfied?
    end

    def invalid?
      !valid?
    end

    def recommendations
      [System.instance.recommendations, @recommendations]
    end

    def publish(raise_exceptions = false)
      @exception = nil

      if invalid?
        @exception = Exception.new("Pull request is invalid")

        raise @exception if raise_exceptions
        return false
      end

      begin
        response = publish_pull_request
        @github_link = response._links.html.href
      rescue Exception => error
        raise if raise_exceptions

        @exception = error
        return false
      end

      true
    end

    def publish!
      publish(true)
    end

    private
    def_delegator "Abak::Flow::Git.instance", :git
    def_delegator "Abak::Flow::Branches", :current_branch
    def_delegator "Abak::Flow::Project.instance", :remotes

    def title
      [current_branch.tracker_task, options[:title]].compact.join(" :: ")
    end

    def comment
      parts = [default_comment, options[:comment]].compact

      parts.empty? ? forgot_task_text : parts.join("\n\n")
    end

    def branch
      return options[:branch] unless options[:branch].nil?

      BRANCH_MAPPING.select { |type,_| current_branch.send "#{type}?" }.values.first
    end

    # TODO : Вынести формирование имени ветки в отдельный метод
    def publish_pull_request
      git.push("origin", current_branch.name)

      opts = [remotes[:upstream].to_s, branch, "#{remotes[:origin].owner}:#{current_branch.name}", title, comment]
      GithubClient.instance.connection.create_pull_request(*opts)
    end

    # TODO : Вынести урл для трекера в отдельный метод
    def default_comment
      "http://jira.dev.apress.ru/browse/#{current_branch.tracker_task}" if current_branch.task?
    end

    def forgot_task_text
      Messages.new("pull_request.publish").t :forgot_task
    end

    # Pull request must have title, title it's a branch name if branch is hotfix
    # or feature. Unless title option must be specify
    #
    # Returns TrueClass or FalseClass
    def requirements_satisfied?
      recommendations.purge!

      multi_ruleset do
        # Facts
        fact :invalid_request_title do
          title.empty?
        end

        fact :invalid_targe_branch do
          branch.nil?
        end

        # Rules
        rule [:invalid_request_title] do
          @recommendations << :specify_title
        end

        rule [:invalid_targe_branch] do
          @recommendations << :specify_branch
        end
      end

      recommendations.empty? ? true : false
    end
  end
end