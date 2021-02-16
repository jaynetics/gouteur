module Gouteur
  # thin wrapper for bundler calls
  class Bundle
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def install(env: {})
      Shell.run(%w[bundle update --quiet --jobs 4], pwd: path, env: env)
    end

    def depends_on?(gem_name)
      Shell.run(%W[bundle info #{gem_name}], pwd: path).success?
    end

    def exec(task, env: {})
      name = task.sub(/bundle exec +/, '')
      Shell.run(%W[bundle exec #{name}], pwd: path, env: env)
    end

    def gemfile_path
      File.join(path, 'Gemfile')
    end
  end
end
