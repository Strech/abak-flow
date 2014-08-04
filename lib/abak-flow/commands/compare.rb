# coding: utf-8
# 101 exit code available

module Abak::Flow
  module Commands
    class Compare
      include ANSI::Code

      def run(args, options)
        Checkup.new.process(Array.new, ::Commander::Command::Options.new)

        current = Manager.git.current_branch
        head = Branch.new(options.head || current)
        base = Branch.new(options.base || head.extract_base_name)

        if head.current?
          say white {
            Manager.locale.word(self, 'updating',
              branch: bold { head },
              upstream: bold { "#{Manager.repository.origin}" })
          }

          head.update
        else
          say yellow {
            Manager.locale.word(self, 'diverging', branch: bold { head })
          }
        end

        say green { head.compare_link(base) }
      end

    end
  end
end
