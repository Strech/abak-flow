# coding: utf-8
module Abak::Flow
  module Commands
    class Checkup
      include ANSI::Code

      def run(args, options)
        process(args, options)

        say green { Manager.locale.success(self) }
      end

      def process(args, options)
        inspector = Inspector.new(call_method: :valid?, collect_attribute: :errors)
        inspector.examine(Manager.configuration, Manager.repository).on_fail do |insp|
          say red { Manager.locale.error(self) }
          say yellow { insp.output }

          exit 100
        end
      end
    end # class Checkup
  end # module Commands
end # module Abak::Flow
