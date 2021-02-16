# this file isn't required by default so rake isn't needed as runtime dependency

require 'rake'
require 'rake/tasklib'

module Gouteur
  # provides a custom rake task
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name

    def initialize(name = :gouteur, *args)
      super()

      self.name = name

      desc 'Run Gouteur' unless ::Rake.application.last_description
      task(name, *args) do |_, task_args|
        # lazy-load gouteur so that the task doesn't impact Rakefile load time
        require 'gouteur'

        success = Gouteur::CLI.call(task_args.extras)
        success || abort('Gouteur failed!')
      end
    end
  end
end
