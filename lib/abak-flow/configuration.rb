# coding: utf-8
#
# Module for access to global abak-flow gem config
# recieved from .git config and environment
#
# Auto generated methods: oauth_user, oauth_token, proxy_server
#
# TODO : Проверять что атрибут из конфига валиден
# TODO : Переименовать модуль
#
# Example
#
#   Abak::Flow::Configuration.oauth_user #=> Strech
#
require "singleton"
require "forwardable"
require "ostruct"

module Abak::Flow
  class Configuration
    include Singleton
    extend Forwardable

    def_delegator "Abak::Flow::Git.instance", :git

    attr_reader :params

    def initialize
      load_git_configuration
      setup_locale
    end

    private
    def load_git_configuration
      git_config = git.config.select { |k, _| k.include? "abak-flow." }
                             .map { |k,v| [convert_param_name_to_method_name(k), v] }

      @params = Params.new(Hash[git_config]).tap do |p|
        p.locale ||= "en"
        p.proxy_server ||= environment_http_proxy
      end
    end

    def setup_locale
      I18n.load_path += Dir.glob(File.join File.dirname(__FILE__), "locales/*.{rb,yml}")
      I18n.locale = params.locale
    end

    def environment_http_proxy
      ENV["http_proxy"] || ENV["HTTP_PROXY"]
    end

    def convert_param_name_to_method_name(name)
      name.sub(/abak-flow./, "").gsub(/\W/, "_")
    end

    class Params < OpenStruct; end
  end
end