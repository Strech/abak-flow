# coding : utf-8
require "i18n"

# TODO : Нужен простой метод, для перевода без скоупа
module Abak::Flow
  class Messages
    extend Forwardable

    attr_reader :scope, :elements

    def initialize(scope)
      Configuration.instance

      @scope = scope
      @elements = []
    end

    # Iterate elements from locale scope (translating online)
    #
    # Returns nothing
    def each
      raise ArgumentError, "No block given" unless block_given?

      elements.each do |key|
        yield translate(key)
      end
    end

    # Put item to elements
    #
    # Returns Symbol
    def push(element)
      @elements << element
    end
    alias :<< :push

    # section header from locale scope
    #
    # Returns String
    def header
      translate :header
    end

    # Print all elements from locale scope without header
    #
    # Returns Symbol
    def to_s
      return "" if elements.empty?

      elements.collect { |element| translate *element } * "\n"
    end

    def print
      return "" if elements.empty?

      all_elements = []
      elements.each_with_index do |element, index|
        all_elements << "#{index + 1}. #{translate(*element)}"
      end

      all_elements * "\n"
    end

    # Print section header from locale scope and all elements from scope
    #
    # Returns String
    def pretty_print
      return "" if elements.empty?

      [header, print] * "\n\n"
    end
    alias :pp :pretty_print

    def translate(key, options = {})
      I18n.t key, {scope: scope}.merge!(options)
    end
    alias :t :translate

    private
    def_delegator :elements, :empty?
  end
end