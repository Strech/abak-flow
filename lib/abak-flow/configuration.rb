# coding: utf-8

module Abak::Flow
  class Configuration
    # TODO: Add old oauth_login and oauth_token
    AVAILABLE_OPTIONS = %w{login password locale http_proxy}.map(&:freeze)
    GITCONFIG_PATTERN = /abak\-flow\.([\w\d\-\_]+)/.freeze

    def initialize(options = nil)
      @_errors = Hash.new
      @options = {
        login: nil,
        password: nil,
        locale: "en",
        http_proxy: ENV["http_proxy"] || ENV["HTTP_PROXY"]
      }

      options.nil? ? define_options_from_gitconfig
        : define_options_from_hash(options)

      create_public_instance_methods
    end

    def rewrite(options)
      define_options_from_hash(options)
      write_to_gitconfig!
    end

    def valid?
      @_errors = Hash.new
      @_errors["login"] = ['blank'] if @options[:login].to_s.empty?
      @_errors["password"] = ['blank'] if @options[:password].to_s.empty?

      @_errors.empty?
    end

    def errors
      ErrorsPresenter.new(self, @_errors)
    end

    private

    def create_public_instance_methods
      AVAILABLE_OPTIONS.each do |name|
        self.class.send(:define_method, name, -> { @options[name.to_sym] })
      end
    end

    def write_to_gitconfig!
      AVAILABLE_OPTIONS.each do |name|
        value = @options[name.to_sym]

        next if value.nil? || value.empty?
        Manager.git.lib.global_config_set("abak-flow.#{name}", value)
      end
    end

    def define_options_from_hash(hash)
      hash.each do|name, value|
        name = underscore(name.to_s)
        next unless AVAILABLE_OPTIONS.include?(name)

        @options[name.to_sym] = value
      end
    end

    def define_options_from_gitconfig
      read_git_config do |name, value|
        name = underscore(name)
        next unless AVAILABLE_OPTIONS.include?(name)

        @options[name.to_sym] = value
      end
    end

    def read_git_config(&block)
      Manager.git.config.each do |option, value|
        matches = option.match(GITCONFIG_PATTERN)
        block.call(underscore(matches[1]), value) if matches && matches[1]
      end
    end

    def underscore(name)
      name.tr("-", "_")
    end

    def dasherize(name)
      name.tr("_", "-")
    end
  end # class Configuration
end # module Abak::Flow
