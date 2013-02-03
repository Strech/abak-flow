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
      if System.ready?
        say_ok "Yaw, you are ready!"
        say System.information.join("\n")
      else
        say_warning "You are not prepared!"
        say System.recommendations.join("\n")
      end
    end
  end

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "-t", "--title STRING", String, "Заголовок для вашего pull request"
    c.option "-c", "--comment STRING", String, "Комментарии для вашего pull request"
    c.option "-b", "--branch STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      opts = {branch: options.branch, title: options.title, comment: options.comment}
      request = PullRequest.new(opts)

      if request.valid?
        say "Let's do it!"
        if request.publish
          say_ok "Yaw, your request publishing"
          say request.github_link
        else
          say_error "Goddamned, something goes wrong"
          say request.exception.message
          say request.exception.backtrace.join("\n")
        end
      else
        say_warning "You are not prepared!"
        say request.recommendations.join("\n")
      end
    end
  end

end