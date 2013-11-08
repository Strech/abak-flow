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
      v = Visitor.new(m.configuration, m.repository, call: :ready?, look_for: :errors)

      if v.ready?
        say ANSI.green { I18n.t("commands.checkup.success") }
      else
        say ANSI.red { I18n.t("commands.checkup.fail") }
        say ANSI.yellow { v.output }
      end
    end
  end # command :checkup

  command :compare do |c|
    c.syntax      = "git request compare"
    c.description = "Сравнить свою ветку с веткой upstream репозитория"

    c.option "--base STRING", String, "Имя ветки с которой нужно сравнить"
    c.option "--head STRING", String, "Имя ветки которую нужно сравнить"

    c.action do |args, options|
      # TODO : Вот это дубль, хочется его как-то более красиво
      m = Manager.new
      v = Visitor.new(m.configuration, m.repository, call: :ready?, look_for: :errors)

      unless v.ready?
        say ANSI.red { I18n.t("commands.compare.fail") }
        say ANSI.yellow { v.output }

        exit 1
      end

      current = m.git.current_branch
      head = Branch.new(options.head || current, m)
      base = Branch.new(options.base || head.pick_up_base_name, m)

      if head.current?
        say ANSI.white {
          I18n.t("commands.compare.updating",
            branch: ANSI.bold { head },
            upstream: ANSI.bold { "#{m.repository.origin}" }) }

        head.update
      else
        say ANSI.yellow {
          I18n.t("commands.compare.diverging",
            branch: ANSI.bold { head }) }
      end

      say ANSI.green { head.compare_link(base) }
    end
  end # command :compare

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "--title STRING", String, "Заголовок для вашего pull request"
    c.option "--body STRING", String, "Текст для вашего pull request"
    c.option "--base STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      m = Manager.new

      head = Branch.new(m.git.current_branch, m)
      base = Branch.new(options.base || head.pick_up_base_name, m)

      title = options.title || head.pick_up_title
      body = [
        options.body || (head.mappable? ? nil : I18n.t("commands.publish.nothing")),
        head.pick_up_body
      ].compact * "\n\n"

      p = PullRequest.new({base: base, head: head, title: title, body: body}, m)
      v = Visitor.new(m.configuration, m.repository, p, call: :ready?, look_for: :errors)

      unless v.ready?
        say ANSI.red { I18n.t("commands.publish.fail") }
        say ANSI.yellow { v.output }

        exit 1
      end

      say ANSI.white {
        I18n.t("commands.publish.updating",
          branch: ANSI.bold { head },
          upstream: ANSI.bold { "#{m.repository.origin}" }) }

      head.update

      say ANSI.white {
        I18n.t("commands.publish.requesting",
          branch: ANSI.bold { "#{m.repository.origin.owner}:#{head}" },
          upstream: ANSI.bold { "#{m.repository.upstream.owner}:#{base}" }) }

      v = Visitor.new(p, call: :publish, look_for: :errors)
      if v.ready?
        say ANSI.green { I18n.t("commands.publish.success", link: p.link) }
      else
        say ANSI.red { I18n.t("commands.publish.fail") }
        say ANSI.yellow { v.output }

        exit 3
      end
    end
  end # command :publish
end
