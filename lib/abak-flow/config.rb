# coding: utf-8
#
# Module for access to global abak-flow gem config
# recieved from .git config and environment
module Abak::Flow
  module Config
    
    def self.init
      init_git_configuration
      init_environment_configuration
    end
    
    def self.init_git_configuration
      config = [git.config("abak-flow.oauth_user"),
                git.config("abak-flow.oauth_token"),
                git.config("abak-flow.proxy_server")]
      
      @@configuration = Cfg.new(*config)
    end
    
    def self.init_environment_configuration
      return unless @@configuration.proxy_server.nil?
      return if environment_http_proxy.blank?
      
      @@configuration.proxy_server = environment_http_proxy
    end
    
    private
    def self.git
      Git.open('.')
    end
    
    def environment_http_proxy
      (ENV['http_proxy'] || ENV['HTTP_PROXY']).strip
    end
    
    class Cfg < Struct.new(:oauth_user, :oauth_token, :proxy_server); end
  end
end