require 'optparse'

module Gouteur
  # command line interface - prints to stdout and returns true or false
  module CLI
    module_function

    def call(argv = ARGV)
      args = option_parser.parse!(argv)

      repos = pick_repos(args)
      if repos.empty?
        puts '', Message.no_repos, ''
        return false
      end

      repos.all? do |repo|
        success, message = Gouteur::Checker.call(repo, force: !!@force)
        puts '', message, ''
        success
      end
    end

    def option_parser
      @force = false

      OptionParser.new do |opts|
        opts.banner = <<~SH
          Usage: gouteur [repos] [options]

          Examples:
            gouteur https://github.com/me/my_repo
            gouteur my_repo # my_repo must be listed in .gouteur.yml

        SH

        opts.separator 'Options:'

        opts.on("-f", "--force", "Force tests, override version constraints") do
          @force = true
        end

        opts.on("-v", "--version", "Show gouteur version") do
          puts "gouteur #{Gouteur::VERSION}"
          exit
        end

        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def pick_repos(args)
      dotfile_repos = Dotfile.repos
      return dotfile_repos if args.empty?

      args.map do |arg|
        if dotfile_repo = dotfile_repos.find { |r| r.name == arg }
          dotfile_repo
        else
          Gouteur::Repo.new(uri: arg)
        end
      end
    end
  end
end
