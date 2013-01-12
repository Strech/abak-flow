# coding: utf-8
#
# Module for access to global abak-flow gem config
# recieved from .git config and environment
#
# Auto generated methods: oauth_user, oauth_token, proxy_server
#
# Example
#
#   Abak::Flow::Config.oauth_user #=> Strech
#
module Abak::Flow
  module Config
    def self.init
      init_git_configuration
      init_environment_configuration

      check_requirements
    end

    def self.params
      @@params
    end

    protected
    def self.init_git_configuration
      git_config = [git.config("abak-flow.oauth_user"),
                    git.config("abak-flow.oauth_token"),
                    git.config("abak-flow.proxy_server")]

      @@params = Params.new(*git_config)
    end

    def self.init_environment_configuration
      return unless params.proxy_server.nil?

      @@params.proxy_server = environment_http_proxy
    end

    def self.check_requirements
      conditions = [params.oauth_user, params.oauth_token].map(&:to_s)

      if conditions.any? { |c| c.empty? }
        raise Exception, "You have incorrect git config. Check [abak-flow] section"
      end
    end

    private
    def self.git
      Git.open('.')
    end

    def self.environment_http_proxy
      ENV['http_proxy'] || ENV['HTTP_PROXY']
    end

    class Params < Struct.new(:oauth_user, :oauth_token, :proxy_server); end

    Params.members.each do |name|
      self.class.send :define_method, name, -> { params[name.to_sym] }
    end
  end
end