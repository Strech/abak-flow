# coding: utf-8
require "ruler"

module Abak::Flow
  class PullRequest
    include Ruler

    attr_reader :errors, :link

    def initialize(params, manager)
      @manager = manager
      @errors = []

      @head = params.fetch(:head)
      @base = params.fetch(:base)
      @title = params.fetch(:title)
      @body = params.fetch(:body)
    end

    def ready?
      @errors = []

      multi_ruleset do
        fact(:head_is_incorrect)  { not @head.valid? }
        fact(:base_is_incorrect)  { not @base.valid? }
        fact(:title_is_incorrect) { @title.empty? }
        fact(:body_is_incorrect)  { @head.tracker_task? ? @body.empty? : false }

        rule([:head_is_incorrect])  { @errors << I18n.t("pull_request.errors.head_is_incorrect") }
        rule([:base_is_incorrect])  { @errors << I18n.t("pull_request.errors.base_is_incorrect") }
        rule([:title_is_incorrect]) { @errors << I18n.t("pull_request.errors.title_is_incorrect") }
        rule([:body_is_incorrect])  { @errors << I18n.t("pull_request.errors.body_is_incorrect") }
      end

      @errors.empty? ? true : false
    end

    def display_name
      I18n.t("pull_request.name")
    end

    def publish
      begin
        head_with_repo = [@manager.repository.origin.owner, @head] * ':'

        response = @manager.github.create_pull_request(
          @manager.repository.upstream.to_s, @base.to_s, head_with_repo, @title, @body)

        @link = response._links.html.href

        true
      rescue Exception => exception
        backtrace = exception.backtrace[0...10] * "\n"

        @errors = ["#{exception.message}\n\n#{backtrace}"]

        false
      end
    end
  end # class PullRequest
end
