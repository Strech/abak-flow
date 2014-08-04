# coding: utf-8
require "forwardable"

module Abak::Flow
  class ErrorsPresenter
    extend Forwardable

    def_delegators :@errors, :empty?, :each, :each_with_index

    def initialize(object, errors)
      @object = object
      @object_errors = errors
      @errors = create_human_readable_errors
    end

    private

    def create_human_readable_errors
      @object_errors.map do |field, errors|
        field_name = Manager.locale.field(@object, field)

        errors = errors.map do |error|
          error = {field: error, options: Hash.new} unless error.is_a?(Hash)
          Manager.locale.error(@object, "#{field}.#{error[:field]}", error[:options])
        end

        "#{field_name} – #{errors * ", "}"
      end
    end
  end
end
