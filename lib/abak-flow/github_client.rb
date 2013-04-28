# coding: utf-8
require "octokit"
require "singleton"

module Abak::Flow
  class GithubClient
    include Singleton

    attr_reader :connection

    def initialize
      @connection = Octokit::Client.new(connection_options)
    end

    # TODO : Метод для получения SHA1 - пул реквест

    private
    def connection_options
      params = Configuration.instance.params

      {login: params[:oauth_user], oauth_token: params[:oauth_token],
       proxy: params[:proxy_server]}
    end
  end
end