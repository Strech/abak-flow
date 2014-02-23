# coding: utf-8
require "commander/import"
require "ansi/code"

module Abak::Flow
  program :name, "Утилита для оформления pull request на github.com"
  program :version, Abak::Flow::VERSION
  program :description, "Утилита, заточенная под git-flow но с использованием github.com"

  default_command :help

  command :checkup do |cmd|
    cmd.syntax      = "git request checkup"
    cmd.description = "Проверить все ли настроено для работы с github и удаленными репозиториями"
    cmd.action Commands::Checkup, :run
  end # command :checkup

  command :compare do |c|
    c.syntax      = "git request compare"
    c.description = "Сравнить свою ветку с веткой upstream репозитория"

    c.option "--base STRING", String, "Имя ветки с которой нужно сравнить"
    c.option "--head STRING", String, "Имя ветки которую нужно сравнить"

    cmd.action Commands::Compare, :run
  end # command :compare

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "--title STRING", String, "Заголовок для вашего pull request"
    c.option "--body STRING", String, "Текст для вашего pull request"
    c.option "--base STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      m = Manager.instance

      head = Branch.new(m.git.current_branch)
      base = Branch.new(options.base || head.extract_base_name)

      title = options.title || head.extract_title
      body  = options.body || head.extract_body

      p = PullRequest.new({base: base, head: head, title: title, body: body}, m)

      v = Visitor.new(m.configuration, m.repository, p, call: :ready?, inspect: :errors)
      v.exit_on_fail(:publish, 1)

      say ANSI.white {
        I18n.t("commands.publish.updating",
          branch: ANSI.bold { head },
          upstream: ANSI.bold { "#{m.repository.origin}" }) }

      head.update

      say ANSI.white {
        I18n.t("commands.publish.requesting",
          branch: ANSI.bold { "#{m.repository.origin.owner}:#{head}" },
          upstream: ANSI.bold { "#{m.repository.upstream.owner}:#{base}" }) }

      v = Visitor.new(p, call: :publish, inspect: :errors)
      v.exit_on_fail(:publish, 2)

      say ANSI.green { I18n.t("commands.publish.success", link: p.link) }
    end
  end # command :publish

  command :done do |c|
    c.syntax      = "git request done"
    c.description = "Удалить ветки (local и origin) в которых велась работа"

    c.action do |args, options|
      m = Manager.instance
      v = Visitor.new(m.configuration, m.repository, call: :ready?, inspect: :errors)
      v.exit_on_fail(:done, 1)

      branch = Branch.new(m.git.current_branch)

      if branch.develop? || branch.master?
        say ANSI.red {
          I18n.t("commands.done.errors.branch_is_incorrect",
            branch: ANSI.bold { branch }) }
        exit 2
      end

      say ANSI.white {
        I18n.t("commands.done.deleting",
          branch: ANSI.bold { branch },
          upstream: ANSI.bold { "#{m.repository.origin}" }) }

      # FIXME : Исправить молчаливую ситуацию
      #         Возможно стоит предупредить о ее отсутствии
      branch.delete_on_remote rescue nil

      say ANSI.white {
        I18n.t("commands.done.deleting",
          branch: ANSI.bold { branch },
          upstream: ANSI.bold { "working tree" }) }

      # TODO : Добавить проверку, что ветка,
      #        в которую надо попасть (master/develop)
      #        существует

      # TODO : Быть может стоит вынести это в настройки
      #        и позволить выбирать, куда отправлять
      #        при удалении ветки, а по умолчанию использовать master
      m.git.checkout(
        branch.extract_base_name(if_undef: Branch::DEVELOPMENT))
      branch.delete_on_local
    end
  end # command :done
end
