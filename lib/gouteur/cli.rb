module Gouteur
  # command line interface - prints to stdout and returns true or false
  module CLI
    module_function

    def call(args = ARGV)
      repos = pick_repos(args)
      if repos.empty?
        puts '', Message.no_repos, ''
        return false
      end

      repos.all? do |repo|
        success, message = Gouteur::Checker.call(repo)
        puts '', message, ''
        success
      end
    end

    def pick_repos(args)
      repos = args.map { |arg| Gouteur::Repo.new(uri: arg) }
      repos = Dotfile.repos if repos.empty?
      repos
    end
  end
end
