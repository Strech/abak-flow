# coding: utf-8
#
# Class for pushing/updating/checking pull requests
require "ruler"

module Abak::Flow
  class PullRequest
    include Ruler
    extend Forwardable

    attr_reader :options

    # New pull request
    #
    # options - Hash with options
    #           target - target branch name
    #           title  - pull request title
    #           body   - pull request body
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
      @recommendations = []
    end

    def valid?
      return false unless System.ready?

      requirements_satisfied?
    end

    def invalid?
      !valid?
    end

    def recommendations
      System.recommendations | @recommendations.dup
    end

    def publish(raise_exceptions = false)
      raise Exception, "Pull request is invalid" if invalid? && raise_exceptions
      return false if invalid?

      #git.push("origin", current_branch.name)
      #connection.create_pull_request(upstream.to_s, target, current_branch.name, title, body)

      true
    end

    def publish!
      publish(true)
    end

    private
    def_delegators "Git", :git
    def_delegators "Project", :upstream
    def_delegators "Branches", :current_branch
    def_delegators "GithubClient", :connection

    # Pull request must have title, title it's a branch name if branch is hotfix
    # or feature. Unless title option must be specify
    #
    # Returns TrueClass or FalseClass
    def requirements_satisfied?
      @recommendations = []

      multi_ruleset do
        # Facts
        fact :title_not_present do
          !options.has_key?(:title) || options[:title].empty?
        end

        fact :invalid_task_name do
          !current_branch.task?
        end

        # Rules
        rule [:title_not_present, :invalid_task_name] do
          @recommendations << specify_title_recommendation
        end
      end

      @recommendations.empty? ? true : false
    end

    def init_dependences
      Project.init
      Config.init
    end

    def specify_title_recommendation
      "Please specify title for your request"
    end

    def title
      [current_branch.task, options[:title]].compact.join(" :: ")
    end

    # ==========================================================================

    # 2. Pull request publishing
    #
    # => pr = PullRequest.new(*attrs)
    # => pr.published?
    # => pr.publish
    # => pr.url

    # 3. Statistics & Cleaning
    #
    # => PullRequest.garbage
    # => PullRequest.clean
    # => PullRequest.clean(hard: true)
  end
end