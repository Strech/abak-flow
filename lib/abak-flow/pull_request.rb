# coding: utf-8
#
# Class for pushing/updating/checking pull requests
require "ruler"

module Abak::Flow
  class PullRequest
    include Ruler

    attr_reader :options

    # Creates new pull request
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
      System.ready?
    end

    def invalid?
      !valid?
    end

    def recommendations
      @recommendations | System.recommendations
    end

    private
    def requirements_satisfied?
      @recommendations = []

      multi_ruleset do
        # Facts
        fact :title_not_present do
          !options.has_key? :title
        end

        # Rules
        rule [:title_not_present] do
          @recommendations << "???"
        end
      end

      @recommendations.empty? ? true : false
    end

    def init_dependences
      Project.init
      Config.init
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