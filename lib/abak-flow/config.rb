# coding: utf-8
#
# Module for access to global abak-flow gem config
# recieved from .git config and environment
module Abak::Flow
  module Config
    
    def self.configuration
      @@configuration
    end
    
    def self.init
      init_git_configuration
      init_environment_configuration
      
      check_requirements
    end
    
    def self.init_git_configuration
      config = [git.config("abak-flow.oauth_user"),
                git.config("abak-flow.oauth_token"),
                git.config("abak-flow.proxy_server")]
      
      @@configuration = C.new(*config)
    end
    
    def self.init_environment_configuration
      return unless configuration.proxy_server.nil?
      
      @@configuration.proxy_server = environment_http_proxy
    end
    
    def self.check_requirements
      conditions = [configuration.oauth_user, configuration.oauth_token].map(&:to_s)
      
      if conditions.any? { |c| c.empty? }
        raise Exception, "You have incorrect git config. Check [abak-flow] namespace"
      end
    end
    
    private
    def self.git
      Git.open('.')
    end
    
    def self.environment_http_proxy
      ENV['http_proxy'] || ENV['HTTP_PROXY']
    end
    
    class C < Struct.new(:oauth_user, :oauth_token, :proxy_server); end
    
    C.members.each do |name|
      self.class.send :define_method, name, -> { configuration[name.to_sym] }
    end
  end
end