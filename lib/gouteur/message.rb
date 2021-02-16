module Gouteur
  # user-facing messages are here so they don't clutter the code
  module Message
    module_function

    def shell_error(args:, pwd:, stderr:)
      <<~MSG
        👨‍🍳 Oh non!

        The command `$ #{args.join(' ')}` failed in `#{pwd}`.

        The original error was:

        #{stderr.chomp}
      MSG
    end

    def success(repo:)
      <<~MSG
        👨‍🍳 Délicieux!

        Your changes to `#{Host.name}` are fine for `#{repo}`. All tasks succeeded.
      MSG
    end

    def no_repos
      <<~MSG
        👨‍🍳 Quoi?

        Found no repos to test. Pass repo URIs as command line arguments or list them under `repos:` in `#{Dotfile.path}`.
      MSG
    end

    def no_tasks(repo:)
      <<~MSG
        👨‍🍳 Quoi?

        You have defined no tasks to run for `#{repo}`.
      MSG
    end

    def no_dependence(repo:)
      <<~MSG
        👨‍🍳 Sacrebleu!

        `#{Host.name}` is not listed in the Gemfile or gemspec of `#{repo}`. Hence it does not make sense to test changes against it.
      MSG
    end

    def broken(repo:, task:, error:)
      <<~MSG
        👨‍🍳 Zut alors!

        Task `#{task}` failed for `#{repo}` even before inserting the new code of `#{Host.name}`.

        This likely means the task is broken or does not exist.

        The original error was:

        #{error}
      MSG
    end

    def broken_after_update(repo:, task:, error:)
      <<~MSG
        👨‍🍳 Répugnant!

        Task `#{task}` failed for `#{repo}` after inserting the new code of `#{Host.name}`.

        This likely means you ruined it! (Or the task is not idempotent. Or this is a bug in gouteur.)

        The original error was:

        #{error}
      MSG
    end

    def skipped_incompatible(repo:)
      <<~MSG
        👨‍🍳 Attention!

        The new version number of `#{Host.name}` is incompatible with the version requirements specified by `#{repo}`.

        Releasing incompatible versions is considered OK by default, so tasks will be SKIPPED in this case. If you want gouteur to FAIL in this case, set the `locked` flag.
      MSG
    end

    def incompatible_failure(error:)
      <<~MSG
        #{error}

        Incompatible version numbers can be allowed by removing the `locked` flag. This will make gouteur SKIP the tasks in this case.
      MSG
    end
  end
end
