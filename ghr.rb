# -*- encoding: utf-8 -*-

require 'rubygems'
require 'commander/import'
require 'hub'

program :name, 'Утилита для оформления pull request на github.com'
program :version, '0.0.1'
program :description, 'Утилита, заточенная под git-flow но с использованием github.com'

command :'request publish' do |c|
  c.syntax      = 'request publish <Заголовок>'
  c.description = 'Оформить pull request из текущей ветки (feature -> develop, hotfix -> master)'

  c.option '--head STRING', String, 'Имя ветки, которую нужно принять в качестве изменений'
  c.option '--base STRING', String, 'Имя ветки, в которую нужно принять изменения'

  c.action do |args, options|
    repository     = Hub::Commands.send :local_repo
    current_branch = repository.current_branch.short_name
    request_rules  = {
      :feature => :develop,
      :hotfix  => :master
    }

    # Проверим, что мы не в мастере или девелопе
    if [:master, :develop].include? current_branch.to_sym
      say 'Нельзя делать pull request из меток master или develop'
      exit
    end

    # Проверим, что у нас настроен upstream
    if repository.remote_by_name('upstream').nil?
      say 'Необходимо настроить репозиторий upstream (главный) для текущего пользователя'
      say '=> git remote add upstream https://Developer@github.com/abak-press/sample.git'
      exit
    end

    # Запушим текущую ветку на origin
    #Hub::Runner.execute('push', repo.main_project.remote.name, current_branch)

    # Овнер проекта
    puts repository.repo_owner

    # Овнер upstream
    puts repository.remote_by_name('upstream').project.owner

    puts options.head


    # Запостим pull request на upstream
    #Hub::Runner.execute('pull-request', 'upstream', args.first, '-b', 'develop', '-h', current_branch)

    #puts options.inspect
    #puts args.inspect
  end
end
alias_command :request, :'request publish'

command :'request update' do |c|

end

command :'request done' do |c|

end