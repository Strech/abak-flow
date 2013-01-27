# coding: utf-8
#
# Module for access to global abak-flow gem config
# recieved from .git config and environment
#
# Auto generated methods: oauth_user, oauth_token, proxy_server
#
# TODO : Проверять что атрибут из конфига валиден
#
# Example
#
#   Abak::Flow::Config.oauth_user #=> Strech
#
module Abak::Flow
  module Config
    def self.init
      reset_variables

      init_git_configuration
      init_environment_configuration
    end

    def self.params
      @@params.dup
    end

    protected
    def self.init_git_configuration
      git_config = [git.config["abak-flow.oauth-user"],
                    git.config["abak-flow.oauth-token"],
                    git.config["abak-flow.proxy-server"]]

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

    def self.git
      Git.git
    end

    def self.environment_http_proxy
      ENV['http_proxy'] || ENV['HTTP_PROXY']
    end

    class Params < Struct.new(:oauth_user, :oauth_token, :proxy_server); end

    Params.members.each do |name|
      self.class.send :define_method, name, -> { params[name.to_sym] }
    end

    private
    def self.reset_variables
      @@params = {}
    end
    reset_variables

  end
end