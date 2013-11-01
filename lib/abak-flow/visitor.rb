# coding: utf-8

module Abak::Flow
  class Visitor
    def initialize(*args)
      options = args.pop if args.last.is_a?(Hash)

      @objects = args
      @call = options.fetch(:call)
      @info = options.fetch(:look_for)

      @asked = false
    end

    def ready?
      @asked = true

      ready = @objects.map { |o| o.send(@call) }.uniq
      ready.size == 1 && ready.first
    end

    def output
      ready? unless asked?

      @objects.map do |o|
        next if o.send(@info).empty?

        info = ""
        name = o.respond_to?(:display_name) ? o.display_name : o.class.name
        o.send(@info).each_with_index do |inf, idx|
          info << "\n  #{idx + 1}. #{inf}"
        end

        "\n#{name}#{info}"
      end * "\n"
    end

    private
    def asked?
      @asked
    end
  end
end
