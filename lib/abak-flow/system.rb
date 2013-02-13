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
      @@recommendations_storage.dup.freeze
    end

    def self.information
      @@information_storage.dup.freeze
    end

    def self.ready?
      reset_variables

      Project.init
      Configuration.init

      multi_ruleset do
        # Facts
        fact :origin_not_set_up do
          Project.origin.nil?
        end

        fact :upstream_not_set_up do
          Project.upstream.nil?
        end

        fact :oauth_user_not_set_up do
          Configuration.oauth_user.nil?
        end

        fact :oauth_token_not_set_up do
          Configuration.oauth_token.nil?
        end

        fact :proxy_server_set_up do
          !Configuration.proxy_server.nil?
        end

        # Rules
        rule [:origin_not_set_up] do
          @@recommendations_storage << :set_up_origin
        end

        rule [:upstream_not_set_up] do
          @@recommendations_storage << :set_up_upstream
        end

        rule [:oauth_user_not_set_up] do
          @@recommendations_storage << :set_up_oauth_user
        end

        rule [:oauth_token_not_set_up] do
          @@recommendations_storage << :set_up_oauth_token
        end

        rule [:proxy_server_set_up] do
          @@information_storage << :set_up_oauth_token
        end
      end

      recommendations_storage.empty? ? true : false
    end

    private
    def self.recommendations_storage
      @@recommendations_storage
    end

    def self.information_storage
      @@information_storage
    end

    def self.reset_variables
      @@recommendations_storage = Messages.new "system.recommendations"
      @@information_storage = Messages.new "system.information"
    end
    reset_variables

  end
end