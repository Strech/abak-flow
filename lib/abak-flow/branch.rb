# coding: utf-8

module Abak::Flow
  class Branch
    FOLDER_HOTFIX  = "hotfix".freeze
    FOLDER_FEATURE = "feature".freeze
    TASK_FORMAT    = '\w+\-\d{1,}'.freeze
    MAGICK_WORDS   = %w{close closes closed fix fixes fixed
                        resolve resolves resolved}.freeze

    DEVELOPMENT = "develop".freeze
    MASTER      = "master".freeze

    MAPPING = {
      FOLDER_HOTFIX  => MASTER,
      FOLDER_FEATURE => DEVELOPMENT
    }.freeze

    attr_reader :folder
    attr_reader :task

    def initialize(branch)
      @manager = Manager.instance
      @branch = branch.is_a?(Git::Branch) ? branch
                                          : @manager.git.branch(branch)

      parse_branch_name
    end

    def name
      @branch.full
    end

    def message
      content = @branch.gcommit.message.split("\n", 2).first
      return content if content.length < 72

      content[0...72] << "..."
    end

    def to_s
      @branch.to_s
    end

    def compare_link(branch)
      diff = "#{@manager.repository.upstream.owner}:#{branch}...#{@branch}"

      File.join [
        @manager.github.web_endpoint,
        @manager.repository.origin.to_s,
        "compare", diff
      ]
    end

    def extract_base_name(options = Hash.new)
      mappable? ? MAPPING[folder]
                : options.fetch(:if_undef, name)
    end

    def extract_title
      tracker_task? ? task
                    : message
    end

    # TODO : Сделать настраевыемым трекер и формат задачи
    def extract_body
      return I18n.t("commands.publish.nothing") if
        tasks_from_commit_message.empty? && !tracker_task?

      [tasks_from_commit_message, task].flatten.compact.uniq
        .map { |x| "http://jira.railsc.ru/browse/#{x}" } * "\n"
    end

    def update
      origin = @manager.repository.origin.repo
      @manager.git.push(origin, @branch)
    end

    def delete_on_remote
      origin = @manager.repository.origin.repo
      @manager.git.push(origin, ":#{@branch}")
    end

    def delete_on_local
      @branch.delete
    end

    def develop?
      name == DEVELOPMENT
    end

    def master?
      name == MASTER
    end

    def hotfix?
      folder == FOLDER_HOTFIX
    end

    def feature?
      folder == FOLDER_FEATURE
    end

    def tracker_task?
      !(task =~ /^#{TASK_FORMAT}$/).nil?
    end

    def mappable?
      hotfix? || feature?
    end

    def current?
      @branch.current
    end

    def valid?
      !@branch.name.empty?
    end

    private
    def tasks_from_commit_message
      @parsed_tasks ||=
        @branch.gcommit.contents
               .scan(/(?:#{MAGICK_WORDS * "|"})\s+(#{TASK_FORMAT})/i)
    end

    def parse_branch_name
      matches = name.match(/^(?<prefix>.+)\/(?<task>.+)$/)

      @folder, @task = matches.nil? ? [nil, nil]
                                    : [matches[:prefix], matches[:task]]
    end
  end
end
