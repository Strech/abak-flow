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
        say "Yaw, you are ready!"
        say System.information
      else
        say "You are not prepared!"
        say System.recommendations.join("\n")
      end
    end

  end
end