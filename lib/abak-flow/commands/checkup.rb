# coding: utf-8
require "ansi/code"

module Abak::Flow
  module Commands
    class Checkup

      def initialize
        manager = Manager.instance

        @configuration = manager.configuration
        @repository = manager.repository
      end

      def run(args, options)
        process(args, options)
        say ANSI.green { I18n.t("commands.checkup.success") }
      end

      def process(args, options)
        Visitor.new(@configuration, @repository,
                    command: "checkup", call: :ready?, inspect: :errors)
               .on_fail(exit: 1)
      end
    end # class Checkup
  end # module Commands
end # module Abak::Flow