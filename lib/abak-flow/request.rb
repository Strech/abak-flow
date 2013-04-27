# coding: utf-8
require "commander/import"

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
        say_ok message.t :you_are_ready
        say System.information.pp
      else
        say_warning message.t :you_are_not_prepared
        say System.recommendations.pp
      end
    end
  end # checkup command

  command :publish do |c|
    c.syntax      = "git request publish"
    c.description = "Оформить pull request в upstream репозиторий"

    c.option "-t STRING", String, "Заголовок для вашего pull request"
    c.option "-c STRING", String, "Комментарии для вашего pull request"
    c.option "-b STRING", String, "Имя ветки, в которую нужно принять изменения"

    c.action do |args, options|
      opts = {base: options.b, title: options.t, comment: options.c}
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

  # command :garbage do |c|
  #   c.syntax      = "git request garbage"
  #   c.description = "Проверить пригодность удаленных (origin) веток и возможность их уничтожения (ветки master, develop игнорируются)"
  #
  #   c.action do |args, options|
  #     message = Messages.new "commands.garbage"
  #
  #     garbage = Branches.garbage
  #
  #     say message.t :searching_for_garbage
  #     if garbage.empty?
  #       say_ok message.t :no_garbage_detected
  #     else
  #       say message.t :garbage_detected
  #       say garbage.to_s
  #     end
  #   end
  # end # garbage command

  # TODO : command clean (without options)

end