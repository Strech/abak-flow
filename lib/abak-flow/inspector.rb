# coding: utf-8
require "ansi/code"

module Abak::Flow
  class Inspector
    def initialize(options = Hash.new)
      @objects = Array.new
      @call_method = options.fetch(:call_method)
      @collect_attribute = options.fetch(:collect_attribute)
    end

    def examine(*args)
      @objects = args
      @fail = @objects.map { |x| x.send(@call_method) }.any? { |x| not !!x }

      self
    end

    def output
      @objects.map do |object|
        next if object.send(@collect_attribute).empty?

        info = ""
        object.send(@collect_attribute).each_with_index do |inf, idx|
          info << "\n  #{idx + 1}. #{inf}"
        end

        "#{Manager.locale.name(object)}#{info}"
      end * "\n"
    end

    def on_fail(&block)
      block.call(self) if @fail
    end
  end # class Inspector
end # module Abak::Flow
