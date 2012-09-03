# -*- encoding: utf-8 -*-
module Abak::Flow
  class PullRequest
    extend Forwardable

    attr_reader :repository, :request_params
    attr_reader :config, :validator

    def initialize(config, options)
      strategy = options.delete(:strategy) || :publish

      @repository = Hub::Commands.send(:local_repo)
      @request_params = OpenStruct.new(options)
      @config = config

      @validator = Validator.new(strategy, self)
    end

    delegate [:validate!, :valid?] => :validator
    delegate [:base=, :head=, :title=, :body=] => :request_params

    def default_task
      @default_task ||= current_branch.split('/').push(nil)[1].to_s
    end

    def branch_prefix
      @branch_prefix  ||= current_branch.include?('/') ? current_branch.split('/').first : ''
    end

    def current_branch
      @current_branch ||= repository.current_branch.short_name
    end

    def from_repo
      @from_repo ||= begin
        upstream_project = repository.remote_by_name('upstream').project
        "#{upstream_project.owner}/#{upstream_project.name}"
      end
    end
    
    def origin_repo
      @origin_repo ||= repository.main_project.remote.name
    end

    def base
      exit unless validator.valid?

      branch = Abak::Flow::PullRequest.branch_by_prefix(branch_prefix)

      request_params.body || "#{repository.remote_by_name('upstream').project.owner}:#{branch}"
    end

    def head
      exit unless validator.valid?

      request_params.head || "#{repository.repo_owner}:#{current_branch}"
    end

    def title
      exit unless validator.valid?

      request_params.title
    end

    def body
      exit unless validator.valid?

      request_params.body
    end

    def self.branch_by_prefix(prefix)
      {:feature => :develop, :hotfix  => :master}.fetch(prefix.to_sym, '')
    end

    # TODO Вынести
    class Validator
      attr_reader :strategy, :target_object
      attr_reader :errors, :executed

      def initialize(strategy_name, target_object)
        @strategy = Abak::Flow::PullRequest.const_get("Strategy#{strategy_name.capitalize}".to_sym)
        @target_object = target_object
        @errors = []
      end

      def valid?
        return errors.empty? if executed

        validate!
        errors.empty?
      end

      protected
      def validate!
        @executed = true

        strategy.attributes.each do |attribute|
          send("validate_#{attribute}")
        end

        print_errors
      end

      def print_errors
        errors.each do |error|
          say color(error[:message], :error).to_s
          say color(error[:tip], :info).to_s
        end
      end

      def validate_api_user
        return if target_object.config.api_user?

        @errors << {
          :message => 'Необходимо указать своего пользователя API github',
          :tip     => '=> https://github.com/Strech/abak-flow/blob/master/README.md'
        }
      end

      def validate_api_token
        return if target_object.config.api_token?

        @errors << {
          :message => 'Необходимо указать токен своего пользователя API github',
          :tip     => '=> https://github.com/Strech/abak-flow/blob/master/README.md'
        }
      end

      def validate_origin
        return unless target_object.repository.remote_by_name('origin').nil?

        @errors << {
          :message => 'Необходимо настроить репозиторий origin (форк) для текущего пользователя',
          :tip     => '=> git remote add origin https://Developer@github.com/abak-press/sample.git'
        }
      end

      def validate_upstream
        return unless target_object.repository.remote_by_name('upstream').nil?

        @errors << {
          :message => 'Необходимо настроить репозиторий upstream (главный) для текущего пользователя',
          :tip     => '=> git remote add upstream https://Developer@github.com/abak-press/sample.git'
        }
      end

      def validate_title
        return unless target_object.request_params.title.empty?

        @errors << {
          :message => 'Пожалуйста, укажите что-нибудь для заголовка pull request, например номер вашей задачи вот так:',
          :tip     => '=> git request publish "PC-001"'
        }
      end

      def validate_branch
        return if [:master, :develop].include?(target_object.current_branch.to_sym)

        @errors << {
          :message => 'Нельзя делать pull request из меток master или develop, попробуйде переключиться, например так:',
          :tip     => '=> git checkout master'
        }
      end

      def validate_deleted_branch
        return unless [:master, :develop].include?(target_object.current_branch.to_sym)

        @errors << {
          :message => 'Извините, но нельзя удалить ветку develop или master',
          :tip     => '=> git checkout feature/TASK-0001'
        }
      end
    end

    class Strategy
      def self.attributes
        raise NotImplementedError
      end
    end

    class StrategyFeature < Strategy
      def self.attributes
        StrategyReadycheck.attributes | [:title, :branch]
      end
    end

    class StrategyPublish < Strategy
      def self.attributes
        StrategyReadycheck.attributes | [:title]
      end
    end

    class StrategyUpdate < Strategy
      def self.attributes
        StrategyReadycheck.attributes
      end
    end

    class StrategyDone < Strategy
      def self.attributes
        StrategyReadycheck.attributes | [:deleted_branch]
      end
    end

    class StrategyReadycheck < Strategy
      def self.attributes
        [:origin, :upstream, :api_user, :api_token]
      end
    end
  end
end