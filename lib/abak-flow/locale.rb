# coding: utf-8
require "i18n"

module Abak::Flow
  class Locale
    FILES = File.join(File.dirname(__FILE__), "locales/*.{rb,yml}").freeze

    def initialize(locale)
      I18n.enforce_available_locales = false
      I18n.load_path += Dir.glob(FILES)
      I18n.locale = locale
    end

    def name(object)
      I18n.t("#{namenize object}.name")
    end

    def field(object, key)
      I18n.t(key, scope: "#{namenize object}.fields")
    end

    def word(object, key, options = {})
      I18n.t(key, options.merge(scope: "#{namenize object}.words"))
    end

    def error(object, key = nil, options = {})
      key.nil? ? I18n.t("#{namenize object}.fail", options)
        : I18n.t(key, options.merge(scope: "#{namenize object}.errors"))
    end

    def success(object, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      key = args[0]

      key.nil? ? I18n.t("#{namenize object}.success", options)
        : I18n.t(key, options.merge(scope: "#{namenize object}.success"))
    end

    private

    def namenize(object)
      object.class.name.downcase.gsub(/\:\:/, ".")
    end
  end # class Locale
end # module Abak::Flow
