require 'yaml'

module Gouteur
  # main process class
  class Checker
    attr_reader :repo, :force

    def self.call(repo, silent: false, force: repo&.force?)
      new(repo, silent: silent, force: force).call
    end

    def initialize(repo, silent: false, force: repo&.force?)
      @repo = repo
      @silent = silent
      @force = force
    end

    def call
      puts "Preparing `#{repo}` for checks..."
      prepare
      check_dependence

      run_tasks(adapted: false)

      repo.gemfile.create_adapted(drop_version_constraint: force)
      repo.remove_host_from_gemspecs if force
      install_adapted_bundle or return handle_incompatible_semver

      run_tasks(adapted: true)

      [true, Message.success(repo: repo)]
    rescue Gouteur::Error => e
      [false, e.message.chomp]
    end

    def prepare
      repo.fetch
      repo.prepare
      result = repo.bundle.install
      result.success? || raise(Error, result.full_error)
    end

    def check_dependence
      repo.bundle.depends_on?(Host.name) ||
        raise(Error, Message.no_dependence(repo: repo))
    end

    def run_tasks(adapted: false)
      repo.tasks.empty? && raise(Error, Message.no_tasks(repo: repo))
      repo.tasks.each { |task| run_task(task, adapted: adapted) }
    end

    def run_task(task, adapted: false)
      puts("Running `#{task}` with #{adapted ? :new : :old} `#{Host.name}`...")
      env = adapted ? adaptation_env : {}
      result = repo.bundle.exec(task, env: env)
      result.success? or raise Error, Message.send(
        adapted ? :broken_after_update : :broken,
        repo: repo, task: task, output: result.stdout, error: result.stderr
      )
    end

    def install_adapted_bundle
      result = repo.bundle.install(env: adaptation_env)
      if result.success?
        true
      elsif indicates_incompatible_semver?(result)
        false
      else
        raise Error, result.full_error
      end
    end

    BUNDLER_INCOMPATIBLE_VERSION_CODE = 6
    BUNDLER_GEM_NOT_FOUND_CODE = 7 # includes some incompatibility cases

    def indicates_incompatible_semver?(result)
      result.exitstatus == BUNDLER_INCOMPATIBLE_VERSION_CODE ||
        result.exitstatus == BUNDLER_GEM_NOT_FOUND_CODE &&
          result.stderr =~ /following gems matching|following version/
    end

    def handle_incompatible_semver
      raise Error, Message.incompatible_failure(repo: repo) if repo.locked?

      [true, Message.skipped_incompatible(repo: repo)]
    end

    def adaptation_env
      {
        'BUNDLE_GEMFILE' => repo.gemfile.adapted_path,
        'SPEC_OPTS' => '--fail-fast', # saves time with rspec tasks
      }
    end

    private

    def puts(*args)
      @silent ? nil : Kernel.puts(*args)
    end
  end
end
