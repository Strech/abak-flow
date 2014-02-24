# coding: utf-8
require "ansi/code"

module Abak::Flow
  class Visitor
    def initialize(*args)
      options = args.pop if args.last.is_a?(Hash)

      @objects = args
      @call = options.fetch(:call)
      @inspect = options.fetch(:inspect)
      @command = options.fetch(:command, "default")

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
        next if o.send(@inspect).empty?

        info = ""
        name = o.respond_to?(:display_name) ? o.display_name : o.class.name
        o.send(@inspect).each_with_index do |inf, idx|
          info << "\n  #{idx + 1}. #{inf}"
        end

        "\n#{name}#{info}"
      end * "\n"
    end

    def exit_on_fail(command, code = 1)
      return if ready?

      say ANSI.red { I18n.t("commands.#{command}.fail") }
      say ANSI.yellow { output }

      exit(code)
    end

    def on_fail(options = Hash.new, &block)
      return if ready?

      say ANSI.red { I18n.t("commands.#{@command}.fail") }
      say ANSI.yellow { output }

      exit(options[:exit]) if options.key?(:exit)
    end

    private
    def asked?
      @asked
    end
  end
end
