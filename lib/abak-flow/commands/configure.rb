# coding: utf-8
require "octokit"

module Abak::Flow
  module Commands
    class Configure
      include ANSI::Code

      def run(args, options)
        process(args, options)

        puts
        say green { Manager.locale.success(self) }
      end

      def process(args, options)
        interview

        password_hash = deffered do
          client = Octokit::Client.new(login: @login, password: @password)
          response = client.create_authorization(
            scopes: ["repo"], note: "abak-flow",
            note_url: "https://github.com/Strech/abak-flow",
            headers: @headers)

          response[:token]
        end

        Manager.configuration.rewrite(
          login: @login, password: password_hash,
          locale: @locale, http_proxy: @http_proxy)
      end

      private

      def interview
        @login = ask("#{Manager.locale.word(self, 'email')}: ")
        @password = password("#{Manager.locale.word(self, 'password')}: ", nil)
        @locale = choose("#{Manager.locale.word(self, 'locale')}:\n", :en, :ru)
        @http_proxy = ask("#{Manager.locale.word(self, 'http_proxy')}: ")
        @headers = {}
      end

      def otp_interview
        @headers = {"X-GitHub-OTP" => ask("#{Manager.locale.word(self, 'sms_otp')}: ")}
      end

      # TODO : Refactor to object
      def deffered(&block)
        progressbar.show
        thread = Thread.new do
          Thread.current[:result] = suppress { block.call }
        end

        loop do
          progressbar.increment
          break if thread.status === false

          if thread.status.nil?
            progressbar.erase_line
            say red { Manager.locale.error(self, 'execution_failed') }

            exit 102
          end

          sleep 0.3
        end

        case thread[:result]
        when Octokit::OneTimePasswordRequired
          progressbar.erase_line
          otp_interview

          return deffered(&block)
        when NilClass
          progressbar.erase_line
          say red { Manager.locale.error(self, 'empty_response') }

          exit 103
        when Exception
          progressbar.erase_line
          say red { thread[:result].message }

          exit 104
        else
          # no-op
        end

        thread[:result]
      end

      def progressbar
        @progressbar ||= Commander::UI::ProgressBar.new(100,
          progress_str: ".", incomplete_str: " ", format: ":title:progress_bar",
          complete_message: "", title: Manager.locale.word(self, 'configuring'))
      end

      def suppress(&block)
        begin
          block.call
        rescue => error
          error
        end
      end

    end # class Configure
  end # module Commands
end # module Abak::Flow
