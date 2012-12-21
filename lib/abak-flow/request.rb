# -*- encoding: utf-8 -*-
module Abak::Flow
  program :name, 'Утилита для оформления pull request на github.com'
  program :version, Abak::Flow::VERSION
  program :description, 'Утилита, заточенная под git-flow но с использованием github.com'

  default_command :help
  command :publish do |c|
    c.syntax      = 'git request publish <Заголовок>'
    c.description = 'Оформить pull request из текущей ветки (feature -> develop, hotfix -> master)'

    # Опции нужны, если человек хочет запушить  `` ветку, с именем отличным от стандарта
    c.option '--head STRING', String, 'Имя ветки, которую нужно принять в качестве изменений'
    c.option '--base STRING', String, 'Имя ветки, в которую нужно принять изменения'

    c.action do |args, options|
      jira_browse_url = 'http://jira.dev.apress.ru/browse/'

      config = Abak::Flow::Config.current
      github_client = Abak::Flow::GithubClient.connect(config)
      request = Abak::Flow::PullRequest.new(config, :head => options.head, :base => options.base)

      title = args.first.to_s.strip
      body = 'Я забыл какая это задача :('

      if request.default_task =~ /^\w+\-\d{1,}$/
        title = request.default_task if title.empty?
        body = jira_browse_url + request.default_task
      end

      request.title = title
      request.body  = body

      exit unless request.valid?

      # Запушим текущую ветку на origin
      say "=> Обновляю ветку #{request.current_branch} на origin"
      Hub::Runner.execute('push', 'origin', request.current_branch)

      # Запостим pull request на upstream
      say '=> Делаю pull request на upstream'
      begin
        result = github_client.create_pull_request(request.from_repo, request.base, request.head, request.title, request.body)
        say color(result._links.html.href, :green).to_s
      rescue => e
        say color(e.message, :error).to_s
        say "\nПроблемы? Попробуйте заглянуть сюда:"
        say color('=> cписок кодов статуса ответа http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html', :info).to_s
      end
    end
  end

  command :update do |c|
    c.syntax      = 'git request update'
    c.description = 'Обновить ветку на удаленном (origin) репозитории'

    c.option '--branch STRING', String, 'Имя ветки, которую нужно обновить'

    c.action do |args, options|
      config = Abak::Flow::Config.current
      request = Abak::Flow::PullRequest.new(config, :strategy => :update)

      exit unless request.valid?

      # Запушим текущую ветку на origin
      branch = options.branch || request.current_branch
      say "=> Обновляю ветку #{branch} на origin"
      Hub::Runner.execute('push', 'origin', branch)
    end
  end

  command :feature do |c|
    c.syntax      = 'git request feature <Название задачи>'
    c.description = 'Создать ветку для выполнения задачи. Лучше всего, если название задачи, будет ее номером из jira'

    c.action do |args, options|
      config = Abak::Flow::Config.current

      task = args.shift.to_s

      if task.empty?
        say color('Необходимо указать имя задачи, а лучше всего ее номер из jira', :error).to_s
        exit
      end

      unless task =~ /^\w+\-\d{1,}$/
        say '=> Вы приняли верное решение :)' && exit if agree("Лучше всего завести задачу с именем примерно такого формата PC-001, может попробуем заново? [y/n]:")
      end

      Hub::Runner.execute('flow', 'feature', 'start', task)
    end
  end

  command :hotfix do |c|
    c.syntax      = 'git request hotfix <Название задачи>'
    c.description = 'Создать ветку для выполнения bugfix задачи. Лучше всего, если название задачи, будет ее номером из jira'

    c.action do |args, options|
      config = Abak::Flow::Config.current

      task = args.shift.to_s

      if task.empty?
        say color('Необходимо указать имя задачи, а лучше всего ее номер из jira', :error).to_s
        exit
      end

      unless task =~ /^\w+\-\d{1,}$/
        say '=> Вы приняли верное решение :)' && exit if agree("Лучше всего завести задачу с именем примерно такого формата PC-001, может попробуем заново? [y/n]:")
      end

      Hub::Runner.execute('flow', 'hotfix', 'start', task)
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
      config  = Abak::Flow::Config.current
      request = Abak::Flow::PullRequest.new(config, :strategy => :done)
      branch  = options.branch || request.current_branch

      exit unless request.valid?

      type = :all
      if [options.local, options.origin].compact.count == 1
        type = options.local ? :local : :origin
      end

      warning = color('Внимание! Alarm! Danger! Achtung!', :error).to_s +
                "\nЕсли вы удалите ветку на удаленном (remote) репозитории, а ваш pull request еще не приняли, вы рискуете потерять проделанную работу.\nВы уверены, что хотите продолжить?"
      if [:all, :origin].include?(type)
        say '=> Вы приняли верное решение :)' && exit unless agree("#{warning} [y/n]:")
      end

      # TODO Проверку на наличие ветки на origin
      if [:all, :origin].include?(type)
        say "=> Удаляю ветку #{branch} на origin"
        Hub::Runner.execute('push', request.origin_repo, ':' + branch)
      end

      if [:all, :local].include?(type)
        say "=> Удаляю локальную ветку #{branch}"
        Hub::Runner.execute('checkout', 'develop')
        Hub::Runner.execute('branch', '-D', branch)
      end
    end
  end

  # TODO Отрефакторить эту какашку
  command :readycheck do |c|
    c.syntax      = 'git request readycheck'
    c.description = 'Проверить все ли настроено для работы с github и удаленным (origin) репозиторием'

    c.action do |args, options|
      config  = Abak::Flow::Config.current
      request = Abak::Flow::PullRequest.new(config, :strategy => :readycheck)

      if config.proxy?
        message = "== В качестве прокси будет установлено значение #{config.proxy} =="
        say color('=' * message.length, :info).to_s
        say color(message, :info).to_s
        say color('=' * message.length + "\n", :info).to_s
      end

      say color('Хм ... кажется у вас все готово к работе', :debug).to_s if request.valid?
    end
  end
  
  command :garbage do |c|
    c.syntax      = 'git request status'
    c.description = 'Проверить пригодность удаленных (origin) веток и возможность их уничтожения'

    c.action do |args, options|
      config  = Abak::Flow::Config.current
      github_client = Abak::Flow::GithubClient.connect(config)
      request = Abak::Flow::PullRequest.new(config, :strategy => :status)
      
      exit unless request.valid?
      
      messages = {unused: ["отсутствует в upstream репозитории", :notice],
                  differ: ["отличается от origin репозитория", :warning],
                  missing: ["отсутствует в локальном репозитории", :warning]}
      
      say "=> Обновляю данные о репозитории upstream"
      %w(origin upstream).each { |remote| Hub::Runner.execute('fetch', remote, '-p') }
      
      say "=> Загружаю список веток для origin\n"
      github_client.branches(request.origin_project).each do |branch|
        next if %w(master develop).include? branch.name
        
        base = Abak::Flow::PullRequest.branch_by_prefix branch.name.split('/').first
        
        upstream_branch = %x(git branch -r --contain #{branch.commit.sha} | grep upstream/#{base} 2> /dev/null).strip
        local_sha = %x(git show #{branch.name} --format=%H --no-notes 2> /dev/null | head -n 1).strip

        statuses = {
          unused: upstream_branch.empty?,
          differ: !local_sha.empty? && local_sha != branch.commit.sha,
          missing: local_sha.empty?
        }
        
        unless statuses.values.inject &:|
          say color("#{branch.name} → можно удалить", :debug).to_s
          say "\n"
          next
        end
        
        diagnoses = statuses.select { |_,bool| bool }.
                             map { |name,_| messages[name].first }.
                             map { |msg| "   ↪ #{msg}" }.
                             join("\n")

        if statuses.select { |_,bool| bool }.keys == [:missing]
          say color("#{branch.name} → потенциально можно удалить", :warning).to_s
          say "#{diagnoses}\n\n"
        else
          say "#{branch.name}\n#{diagnoses}\n\n"
        end
      end
    end
  end
end