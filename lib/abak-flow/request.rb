# -*- encoding: utf-8 -*-
module Abak::Flow
  # @TODO Сделать класс, в котором собрать общие куски из задач

  program :name, 'Утилита для оформления pull request на github.com'
  program :version, '0.0.1'
  program :description, 'Утилита, заточенная под git-flow но с использованием github.com'

  default_command :help
  command :publish do |c|
    c.syntax      = 'git request publish <Заголовок>'
    c.description = 'Оформить pull request из текущей ветки (feature -> develop, hotfix -> master)'

    # Опции нужны, если человек хочет запушить ветку, с именем отличным от стандарта
    c.option '--head STRING', String, 'Имя ветки, которую нужно принять в качестве изменений'
    c.option '--base STRING', String, 'Имя ветки, в которую нужно принять изменения'

    c.action do |args, options|
      repository     = Hub::Commands.send :local_repo
      current_branch = repository.current_branch.short_name
      request_rules  = {
        :feature => :develop,
        :hotfix  => :master
      }
      jira_browse_url = 'http://jira.dev.apress.ru/browse/'

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

      if args.first.to_s.empty?
        say 'Пожалуйста, укажите в заголовке номер вашей задачи, например так:'
        say '=> git request "PC-001"'
        exit
      end

      # Расставим ветки согласно правилам
      remote_branch, task = current_branch.split('/').push(nil).map(&:to_s)
      head = "#{repository.repo_owner}:#{current_branch}"
      base = "#{repository.remote_by_name('upstream').project.owner}:#{request_rules.fetch(remote_branch.to_sym, '')}"

      head = options.head unless options.head.nil?
      base = options.base unless options.base.nil?

      # Запушим текущую ветку на origin
      # @TODO Может быть лучше достать дерективу конфига origin?
      say "=> Обновляю ветку #{current_branch} на origin"
      Hub::Runner.execute('push', repository.main_project.remote.name, current_branch)

      # Запостим pull request на upstream
      command_options = ['pull-request', args.first, '-b', base, '-h', head, '-d']
      command_options |= ['-d', jira_browse_url + task] if task =~ /^\w+\-\d{1,}$/

      say '=> Делаю pull request на upstream'
      say Hub::Runner.execute(*command_options)
    end
  end

  command :update do |c|
    c.syntax      = 'git request update'
    c.description = 'Обновить ветку на удаленном (origin) репозитории'

    c.option '--branch STRING', String, 'Имя ветки, которую нужно обновить'

    c.action do |args, options|
      repository     = Hub::Commands.send :local_repo
      current_branch = repository.current_branch.short_name

      # Запушим текущую ветку на origin
      branch = options.branch || current_branch
      say "=> Обновляю ветку #{branch} на origin"
      Hub::Runner.execute('push', repository.main_project.remote.name, branch)
    end
  end

  command :done do |c|
    c.syntax      = 'git request done'
    c.description = 'Завершить pull request. По умолчанию удаляются ветки как локальная (local), так и удаленная (origin)'

    c.option '--branch STRING', String, 'Имя ветки pull request которой нужно закрыть'
    c.option '--all', 'Удаляет ветку в локальном репозитории и в удалнном (local + origin) (по умолчанию)'
    c.option '--local', 'Удаляет ветку только в локальном репозитории (local)'
    c.option '--origin', 'Удаляет ветку в удаленном репозитории (origin)'

    c.action do |args, options|
      repository     = Hub::Commands.send :local_repo
      current_branch = repository.current_branch.short_name
      branch         = options.branch || current_branch

      type = :all
      if [options.local, options.origin].compact.count == 1
        type = options.local ? :local : :origin
      end

      warning = "Внимание! Alarm! Danger! Achtung\nЕсли вы удалите ветку на удаленном репозитории, а ваш pull request еще не приняли, вы рискуете потерять проделанную работу.\nВы уверены, что хотите продолжить?"
      if [:all, :origin].include?(type)
        say '=> Вы приняли верное решение :)' && exit unless agree("#{warning} [yes/no/y/n]:")
      end

      if [:all, :origin].include? type
        say "=> Удаляю ветку #{branch} на origin"
        Hub::Runner.execute('push', repository.main_project.remote.name, ':' + branch)
      end

      if [:all, :local].include? type
        remote_branch, task = current_branch.split('/').push(nil).map(&:to_s)

        say "=>  Удаляю локальную ветку #{branch}"
        Hub::Runner.execute('checkout', 'develop')
        Hub::Runner.execute('branch', '-D', branch)
      end
    end
  end
end