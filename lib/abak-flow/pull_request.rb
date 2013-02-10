# coding: utf-8
#
# Class for pushing/updating/checking pull requests
require "ruler"

module Abak::Flow
  class PullRequest
    include Ruler
    extend Forwardable

    attr_reader :options
    attr_reader :github_link
    attr_reader :exception

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
      init_dependences

      @options = options
      @recommendations_storage = Messages.new "pull_request.recommendations"
    end

    def valid?
      return false unless System.ready?

      requirements_satisfied?
    end

    def invalid?
      !valid?
    end

    def recommendations
      [System.recommendations, @recommendations_storage.dup.freeze]
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
    def_delegators Git, :git
    def_delegators Project, :upstream
    def_delegators Branches, :current_branch
    def_delegators GithubClient, :connection

    attr_reader :recommendations_storage

    # Pull request must have title, title it's a branch name if branch is hotfix
    # or feature. Unless title option must be specify
    #
    # Returns TrueClass or FalseClass
    def requirements_satisfied?
      # TODO : Написать метод по очистке Messages#flush
      @recommendations_storage = Messages.new "pull_request.recommendations"

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
          @recommendations_storage << :specify_title
        end

        rule [:invalid_targe_branch] do
          @recommendations_storage << :specify_branch
        end
      end

      recommendations_storage.empty? ? true : false
    end

    def init_dependences
      Project.init
      Config.init
    end

    def forgot_task_text
      "Sorry, i forgot my task number. Ask me personally if you have any questions"
    end

    def title
      [current_branch.tracker_task, options[:title]].compact.join(" :: ")
    end

    def comment
      parts = [default_comment, options[:comment]].compact

      parts.empty? ? forgot_task_text : parts.join("\n\n")
    end

    def branch
      return options[:branch] unless options[:branch].nil?

      branch_mapping.select { |method,_| current_branch.send "#{method}?" }.
                     values.first
    end

    # TODO : Вынести формирование имени ветки в отдельный метод
    # TODO : Проверять, нет ли уже оформленного реквеста
    def publish_pull_request
      git.push("origin", current_branch.name)

      opts = [upstream.to_s, branch, "#{Project.origin.owner}:#{current_branch.name}", title, comment]
      connection.create_pull_request(*opts)
    end


    # TODO : Вынести урл для трекера в отдельный метод
    def default_comment
      "http://jira.dev.apress.ru/browse/#{current_branch.tracker_task}" if current_branch.task?
    end

    def branch_mapping
      {feature: "develop", hotfix: "master"}
    end

    # ==========================================================================
    # 3. Statistics & Cleaning
    #
    # => PullRequest.garbage
    # => PullRequest.clean
    # => PullRequest.clean(hard: true)
  end
end