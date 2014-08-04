# coding: utf-8
module Abak::Flow
  module Commands
    class Publish
      include ANSI::Code

      def run(args, options)
        Checkup.new.process(Array.new, ::Commander::Command::Options.new)

        head = Branch.new(Manager.git.current_branch)
        base = Branch.new(options.base || head.extract_base_name)

        title = options.title || head.extract_title
        body  = options.body || head.extract_body

        pr = PullRequest.new(base: base, head: head, title: title, body: body)
        validate_request(pr)

        say white {
          Manager.locale.word(self, "updating",
            branch: bold { head },
            upstream: bold { "#{Manager.repository.origin}" })
        }

        head.update

        say white {
          Manager.locale.word(self, "publicating",
            branch: bold { "#{Manager.repository.origin.owner}:#{head}" },
            upstream: bold { "#{Manager.repository.origin}" })
        }

        publicate_request(pr)

        say green { pr.link }
      end

      private

      def validate_request(request)
        inspector = Inspector.new(call_method: :valid?, collect_attribute: :errors)
        inspector.examine(request).on_fail do |insp|
          say red { Manager.locale.error(self) }
          say yellow { insp.output }

          exit 106
        end
      end

      def publicate_request(request)
        inspector = Inspector.new(call_method: :publish, collect_attribute: :errors)
        inspector.examine(request).on_fail do |insp|
          say red { Manager.locale.error(self, 'publication.failed') }
          say yellow { insp.output }

          exit 107
        end
      end

    end
  end
end
