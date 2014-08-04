# coding: utf-8
module Abak::Flow
  class PullRequest
    attr_reader :link

    def initialize(params)
      @_errors = Hash.new

      @head = params.fetch(:head)
      @base = params.fetch(:base)
      @title = params.fetch(:title)
      @body = params.fetch(:body)
    end

    def valid?
      @_errors = Hash.new
      @_errors["head"] = ["invalid"] unless @head.valid?
      @_errors["base"] = ["invalid"] unless @base.valid?
      @_errors["title"] = ["blank"] if @title.empty?

      @_errors.empty?
    end

    def errors
      ErrorsPresenter.new(self, @_errors)
    end

    def publish
      @_errors = Hash.new

      begin
        head_with_repo = [Manager.repository.origin.owner, @head] * ':'

        response = Manager.github.create_pull_request(
          Manager.repository.upstream.to_s, @base.to_s, head_with_repo, @title, @body)

        @link = response[:html_url]

        true
      rescue Exception => exception
        backtrace = exception.backtrace[0...10] * "\n"

        @_errors["exception"] = [{
          field: "message",
          options: {backtrace: "#{exception.message}\n\n#{backtrace}"}
        }]

        false
      end
    end
  end # class PullRequest
end
