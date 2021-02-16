require 'open3'

module Gouteur
  # thin wrapper for Open3
  module Shell
    module_function

    def run(args, pwd: Dir.pwd, env: {})
      stdout, stderr, status = begin
        Bundler.with_original_env { Open3.capture3(env, *args, chdir: pwd) }
      rescue Errno::ENOENT => e
        # bring errors such as "command not found: bundle" into the same form
        ['', e.message, $?]
      end

      Result.new(
        args: args, pwd: pwd, stdout: stdout, stderr: stderr, status: status
      )
    end

    def run!(args, pwd: Dir.pwd, env: {})
      result = run(args, pwd: pwd, env: env)
      result.success? || raise(Error, result.full_error)
      result
    end

    # return value object of Shell methods
    class Result
      attr_reader :stdout, :stderr, :exitstatus

      def initialize(args:, pwd:, stdout:, stderr:, status:)
        @args = args
        @pwd = pwd
        @stdout = stdout
        @stderr = stderr
        @exitstatus = status.exitstatus
      end

      def success?
        exitstatus.zero?
      end

      def full_error
        return nil if success?

        Message.shell_error(args: @args, pwd: @pwd, stderr: stderr)
      end
    end
  end
end
