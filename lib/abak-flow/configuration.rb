# coding: utf-8
require "i18n"
require "ruler"

module Abak::Flow
  class Configuration
    include Ruler

    OPTIONS = [:oauth_user, :oauth_token, :locale, :http_proxy].freeze
    LOCALE_FILES = File.join(File.dirname(__FILE__), "locales/*.{rb,yml}").freeze

    attr_reader :errors

    def initialize(manager)
      @manager = manager
      @errors = []

      configure!
    end

    def ready?
      @errors = []

      multi_ruleset do
        fact(:oauth_user_not_setup)  { oauth_user.nil? }
        fact(:oauth_token_not_setup) { oauth_token.nil? }

        rule([:oauth_user_not_setup])  { @errors << I18n.t("configuration.errors.oauth_user_not_setup") }
        rule([:oauth_token_not_setup]) { @errors << I18n.t("configuration.errors.oauth_token_not_setup") }
      end

      @errors.empty? ? true : false
    end

    def display_name
      I18n.t("configuration.name")
    end

    private
    def configure!
      load_gitconfig
      setup_locale
    end

    def setup_locale
      I18n.enforce_available_locales = false
      I18n.load_path += Dir.glob(LOCALE_FILES)
      I18n.locale = locale
    end

    def load_gitconfig
      git_config = @manager.git.config.select { |k, _| k.include? "abak-flow." }
                               .map { |k,v| [to_method_name(k), v] }

      config = Hash[git_config]
      config[:locale] ||= "en"
      config[:http_proxy] ||= ENV["http_proxy"] || ENV["HTTP_PROXY"]

      OPTIONS.each do |name|
        define_singleton_method(name) { config[name] }
      end
    end

    def to_method_name(name)
      name.sub(/abak-flow./, "").gsub(/\W/, "_").to_sym
    end
  end
end
