module Abak::Flow
  class Messages

    def initialize(scope)
    end

    # Iterate elements from locale scope (translating online)
    #
    #
    def each
    end

    # Print all elements from locale scope without header
    #
    # Returns Symbol
    def to_s
    end

    # Put item to elements
    #
    # Returns Symbol
    def push(element)
    end
    alias :<< :push

    # section header from locale scope
    #
    # Returns String
    def header
    end

    # Print section header from locale scope and all elements from scope
    #
    # Returns String
    def pretty_print
    end
    alias :pp :pretty_print

  end
end