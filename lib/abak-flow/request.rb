# -*- encoding: utf-8 -*-
module Abak::Flow
  program :name, "Утилита для оформления pull request на github.com"
  program :version, Abak::Flow::VERSION
  program :description, "Утилита, заточенная под git-flow но с использованием github.com"

  default_command :help

  command :checkup do |c|
    c.syntax      = "git request checkup"
    c.description = "Проверить все ли настроено для работы с github и удаленными репозиториями"

    c.action do |args, options|
      message = Messages.new "commands.checkup"

      if System.ready?
        say_ok message.t(:you_are_ready)
        say System.information.pp
      else
        say_warning message.t(:you_are_not_prepared)
        say System.recommendations.pp
      end
    end
  end # checkup command

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "-t", "--title STRING", String, "Заголовок для вашего pull request"
    c.option "-c", "--comment STRING", String, "Комментарии для вашего pull request"
    c.option "-b", "--branch STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      opts = {branch: options.branch, title: options.title, comment: options.comment}
      request = PullRequest.new(opts)

      message = Messages.new "commands.publish"

      if request.valid?
        say message.t(:lets_do_it)

        if request.publish
          say_ok message.t(:request_published)
          say request.github_link
        else
          say_error message.t(:something_goes_wrong)
          say request.exception.message
          say request.exception.backtrace * "\n"
        end
      else
        say_warning message.t(:you_are_not_prepared)
        say request.recommendations.select { |m| !m.empty? }
                                   .collect(&:pp) * "\n"
      end
    end
  end  # publish command

  # TODO : command garbage
  # TODO : command clean (without options)

end