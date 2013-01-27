# coding: utf-8
#
# Module for Gem & Environment settings checking
require "ruler"

module Abak::Flow
  module System
    extend Ruler

    def self.recomendations
      @@recomendations.dup
    end

    def self.information
      @@information.dup
    end

    def self.ready?
      reset_variables

      ::Abak::Flow::Project.init
      ::Abak::Flow::Config.init

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
          @@recomendations << recomendation_set_up_origin
        end

        rule [:upstream_not_set_up] do
          @@recomendations << recomendation_set_up_upstream
        end

        rule [:oauth_user_not_set_up] do
          @@recomendations << recomendation_set_up_oauth_user
        end

        rule [:oauth_token_not_set_up] do
          @@recomendations << recomendation_set_up_oauth_token
        end

        rule [:proxy_server_set_up] do
          @@information << information_proxy_server_set_up
        end
      end
    end

    private
    def self.reset_variables
      @@recomendations = []
      @@information = []
    end
    reset_variables

    def recomendation_set_up_origin
      "Set up your origin"
    end

    def recomendation_set_up_upstream
      "Set up your upstream"
    end

    def recomendation_set_up_oauth_user
      "Set up your abak-flow.oauth_user"
    end

    def recomendation_set_up_oauth_token
      "Set up your abak-flow.oauth_token"
    end

    def information_proxy_server_set_up
      "You set up the custom proxy server"
    end
  end
end