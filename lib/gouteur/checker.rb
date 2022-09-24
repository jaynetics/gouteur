require 'yaml'

module Gouteur
  # main process class
  class Checker
    attr_reader :repo

    def self.call(repo, silent: false)
      new(repo, silent: silent).call
    end

    def initialize(repo, silent: false)
      @repo = repo
      @silent = silent
    end

    def call
      puts "Preparing `#{repo}` for checks..."
      prepare
      check_dependence

      run_tasks(adapted: false)

      create_adapted_gemfile
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

    def create_adapted_gemfile
      content = File.exist?(gemfile_path) ? File.read(gemfile_path) : ''
      adapted_content = adapt_gemfile_content(content)
      File.open(adapted_gemfile_path, 'w') { |f| f.puts(adapted_content) }
    end

    def adapt_gemfile_content(content)
      new_entry = "gem '#{Host.name}', path: '#{Host.root}' # set by gouteur "

      existing_ref_pattern =
        /^ *gem +(?<q>'|")#{Host.name}\k<q>(?<v> *,\s*(?<q2>'|")[^'"]+\k<q2>*)?/

      if content =~ existing_ref_pattern
        content.gsub(existing_ref_pattern) do
          # keep version specification if there was one
          new_entry.sub(/(?=, path:)/, Regexp.last_match[:v].to_s)
        end
      else
        "#{content}\n#{new_entry}\n"
      end
    end

    def gemfile_path
      repo.bundle.gemfile_path
    end

    def adapted_gemfile_path
      "#{repo.bundle.gemfile_path}.gouteur"
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
        'BUNDLE_GEMFILE' => adapted_gemfile_path,
        'SPEC_OPTS' => '--fail-fast', # saves time with rspec tasks
      }
    end

    private

    def puts(*args)
      @silent ? nil : Kernel.puts(*args)
    end
  end
end
