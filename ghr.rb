# -*- encoding: utf-8 -*-

require 'rubygems'
require 'commander/import'
require 'hub'

# :name is optional, otherwise uses the basename of this executable
program :name, 'Утилита для оформления pull request на github.com'
program :version, '1.0.0'
program :description, 'Утилита, заточенная под git-flow но с использованием github.com'

command :'request make' do |c|
  c.syntax      = 'request make <Заголовок>'
  c.description = 'Оформить pull request из текущей ветки (feature -> develop, hotfix -> master)'

  c.option '--head STRING', String, 'Имя ветки, которую нужно принять в качестве изменений'
  c.option '--base STRING', String, 'Имя ветки, в которую нужно принять изменения'

  c.action do |args, options|
    repo = Hub::Commands.send(:local_repo)
    current_branch = repo.current_branch.short_name

    # Проверим что мы не в мастере или девелопе
    if [:master, :develop].include? current_branch.to_sym
      say 'Нельзя делать pull request из меток master или develop'
      exit
    end

    puts

    # Проверить что проект тот

    # Запушим текущую ветку на origin

    # Запостим pull request на upstream

    puts options.inspect
    puts args.inspect
  end
end
alias_command :request, :'request make'