# coding: utf-8

module Abak::Flow
  module Commands
    class Checkup

      def initialize
        manager = Manager.instance

        @configuration = manager.configuration
        @repository = manager.repository
      end

      def run(args, options)
        Visitor.new(@configuration, @repository,
                    command: "checkup", call: :ready?, inspect: :errors)
               .on_fail(exit: 1)

        say ANSI.green { I18n.t("commands.checkup.success") }
      end

    end
  end
end