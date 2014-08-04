# coding: utf-8
require "commander/import"

# TODO : I18n
# TODO : Переименовать в CLI
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

  command :compare do |cmd|
    cmd.syntax      = "git request compare"
    cmd.description = "Сравнить свою ветку с веткой upstream репозитория"

    cmd.option "--base STRING", String, "Имя ветки с которой нужно сравнить"
    cmd.option "--head STRING", String, "Имя ветки которую нужно сравнить"

    cmd.action Commands::Compare, :run
  end # command :compare

  command :configure do |cmd|
    cmd.syntax      = "git request setup"
    cmd.description = "Настроить приложение abak-flow для работы с github"
    cmd.action Commands::Configure, :run
  end # command :configure

  command :publish do |cmd|
    cmd.syntax      = "git request publish"
    cmd.description = "Оформить pull request в upstream репозиторий"

    cmd.option "--title STRING", String, "Заголовок для вашего pull request"
    cmd.option "--body STRING", String, "Текст для вашего pull request"
    cmd.option "--base STRING", String, "Имя ветки, в которую нужно принять изменения"

    cmd.action Commands::Publish, :run
  end # command :publish

  command :done do |cmd|
    cmd.syntax      = "git request done"
    cmd.description = "Удалить ветки (local и origin) в которых велась работа"
    cmd.action Commands::Done, :run
  end # command :done
end
