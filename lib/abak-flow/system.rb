# coding: utf-8
#
# Module for Gem & Environment settings checking
require "ruler"
require "singleton"

module Abak::Flow
  class System
    include Singleton
    include Ruler

    attr_reader :recommendations, :information

    def initialize
      reset_variables
    end

    def ready?
      reset_variables

      multi_ruleset do
        # Facts
        fact :origin_not_set_up do
          Project.instance.remotes[:origin].nil?
        end

        fact :upstream_not_set_up do
          Project.instance.remotes[:upstream].nil?
        end

        fact :oauth_user_not_set_up do
          Configuration.instance.params.oauth_user.nil?
        end

        fact :oauth_token_not_set_up do
          Configuration.instance.params.oauth_token.nil?
        end

        fact :proxy_server_set_up do
          !Configuration.instance.params.proxy_server.nil?
        end

        # Rules
        rule [:origin_not_set_up] do
          @recommendations << :set_up_origin
        end

        rule [:upstream_not_set_up] do
          @recommendations << :set_up_upstream
        end

        rule [:oauth_user_not_set_up] do
          @recommendations << :set_up_oauth_user
        end

        rule [:oauth_token_not_set_up] do
          @recommendations << :set_up_oauth_token
        end

        rule [:proxy_server_set_up] do
          @information << :set_up_oauth_token
        end
      end

      recommendations.empty? ? true : false
    end

    private
    def reset_variables
      @recommendations = Messages.new "system.recommendations"
      @information = Messages.new "system.information"
    end
  end
end