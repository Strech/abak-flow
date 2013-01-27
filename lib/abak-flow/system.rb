# coding: utf-8
#
# TODO : Выделить сообщение в какую-то другую форму
#
# Module for Gem & Environment settings checking
require "ruler"

module Abak::Flow
  module System
    extend Ruler

    def self.recommendations
      @@recommendations.dup
    end

    def self.information
      @@information.dup
    end

    def self.ready?
      reset_variables

      Project.init
      Config.init

      multi_ruleset do
        # Facts
        fact :origin_not_set_up do
          Project.origin.nil?
        end

        fact :upstream_not_set_up do
          Project.upstream.nil?
        end

        fact :oauth_user_not_set_up do
          Config.oauth_user.nil?
        end

        fact :oauth_token_not_set_up do
          Config.oauth_token.nil?
        end

        fact :proxy_server_set_up do
          !Config.proxy_server.nil?
        end

        # Rules
        rule [:origin_not_set_up] do
          @@recommendations << recomendation_set_up_origin
        end

        rule [:upstream_not_set_up] do
          @@recommendations << recomendation_set_up_upstream
        end

        rule [:oauth_user_not_set_up] do
          @@recommendations << recomendation_set_up_oauth_user
        end

        rule [:oauth_token_not_set_up] do
          @@recommendations << recomendation_set_up_oauth_token
        end

        rule [:proxy_server_set_up] do
          @@information << information_proxy_server_set_up
        end
      end

      recommendations.empty? ? true : false
    end

    private
    def self.recomendation_set_up_origin
      "Set up your origin"
    end

    def self.recomendation_set_up_upstream
      "Set up your upstream"
    end

    def self.recomendation_set_up_oauth_user
      "Set up your abak-flow.oauth-user"
    end

    def self.recomendation_set_up_oauth_token
      "Set up your abak-flow.oauth-token"
    end

    def self.information_proxy_server_set_up
      "You set up the custom proxy server"
    end

    def self.reset_variables
      @@recommendations = []
      @@information = []
    end
    reset_variables

  end
end