# coding: utf-8
require "commander/blank"
require "commander/command"

module Abak::Flow
  module Commands
    class Compare
      def initialize
        manager = Manager.instance

        @configuration = manager.configuration
        @repository = manager.repository
        @git = manager.git
      end

      def run(args, options)
        Checkup.new.run(Array.new, ::Commander::Command::Options.new)

        current = @git.current_branch
        head = Branch.new(options.head || current)
        base = Branch.new(options.base || head.extract_base_name)

        if head.current?
          say ANSI.white {
            I18n.t("commands.compare.updating",
              branch: ANSI.bold { head },
              upstream: ANSI.bold { "#{@repository.origin}" }) }

          head.update
        else
          say ANSI.yellow {
            I18n.t("commands.compare.diverging",
              branch: ANSI.bold { head }) }
        end

        say ANSI.green { head.compare_link(base) }
      end

    end
  end
end