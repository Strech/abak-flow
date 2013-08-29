# coding: utf-8
require "commander/import"
require "ansi/code"

module Abak::Flow
  program :name, "Утилита для оформления pull request на github.com"
  program :version, Abak::Flow::VERSION
  program :description, "Утилита, заточенная под git-flow но с использованием github.com"

  default_command :help

  command :checkup do |c|
    c.syntax      = "git request checkup"
    c.description = "Проверить все ли настроено для работы с github и удаленными репозиториями"

    c.action do |args, options|
      m = Manager.new
      v = Visitor.new(m.configuration, m.repository, ask: :ready?, look_for: :errors)

      if v.ready?
        say ANSI.green { I18n.t("commands.checkup.success") }
      else
        say ANSI.red { I18n.t("commands.checkup.fail") }
        say ANSI.yellow { v.output }
      end
    end
  end # checkup command

  command :compare do |c|
    c.syntax      = "git request compare"
    c.description = "Сравнить свою ветку с веткой upstream репозитория"

    c.option "--base STRING", String, "Имя ветки с которой нужно сравнить"
    c.option "--head STRING", String, "Имя ветки которую нужно сравнить"

    c.action do |args, options|
      m = Manager.new

      head = options.head || m.git.branches[m.git.current_branch]

      link = [
        m.github.web_endpoint,
        m.repository.origin.to_s,
        "compare",
        "#{m.repository.upstream.owner}:#{options.base}...#{head}",
      ]

      say ANSI.green { File.join(link) }
    end
  end

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "--title STRING", String, "Заголовок для вашего pull request"
    c.option "--body STRING", String, "Текст для вашего pull request"
    c.option "--base STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      p [args, options]

      #opts = {base: options.b, title: options.t, comment: options.c}
      #request = PullRequest.new(opts)

      #message = Messages.new "commands.publish"

      #if request.valid?
        #say message.t(:lets_do_it)

        #if request.publish
          #say_ok message.t(:request_published)
          #say request.github_link
        #else
          #say_error message.t(:something_goes_wrong)
          #say request.exception.message
          #say request.exception.backtrace * "\n"
        #end
      #else
        #say_warning message.t(:you_are_not_prepared)
        #say request.recommendations.select { |m| !m.empty? }
                                   #.collect(&:pp) * "\n"
      #end
    end
  end  # publish command
end
