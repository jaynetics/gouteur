require 'uri'

module Gouteur
  # a repository of code that depends on the library under test
  class Repo
    attr_reader :uri, :name, :ref, :tasks
    alias to_s name

    def initialize(
      uri:,
      name:   nil,
      ref:    nil,
      before: [],
      tasks:  'rake',
      locked: false,
      force:  false
    )
      @uri    = uri
      @name   = name || extract_name_from_uri(uri)
      @ref    = ref
      @before = Array(before)
      @tasks  = Array(tasks)
      @locked = !!locked
      @force  = !!force
    end

    def fetch
      cloned? ? pull : clone
    end

    def prepare
      @before.each { |cmd| Shell.run!(cmd, pwd: clone_path) }
    end

    def remove
      cloned? && Shell.run!(%W[rm -rf #{clone_path}])
    end

    def clone_path
      File.join(store_dir, name)
    end

    def bundle
      @bundle ||= Gouteur::Bundle.new(clone_path)
    end

    def gemfile
      @gemfile ||= Gouteur::Gemfile.new(bundle.gemfile_path)
    end

    def locked?
      @locked
    end

    def force?
      @force
    end

    def remove_host_from_gemspecs
      Dir[File.join(clone_path, '*.gemspec')].each do |gemspec_path|
        content = File.read(gemspec_path)
        new_content = content.gsub(/^.+_dependency.+\b#{Host.name}\b.+$/, '')
        File.write(gemspec_path, new_content)
      end
    end

    private

    def extract_name_from_uri(uri)
      uri[%r{git(?:hub|lab)\.com/[^/]+/([^/]+)}, 1] ||
        uri.split('/').last.to_s[/[a-z0-9\-_]+/i] ||
        raise(Error, 'could not determine repository name from uri')
    end

    def cloned?
      File.exist?(clone_path)
    end

    def pull
      Shell.run!(%w[git fetch origin], pwd: clone_path)
      Shell.run!(%w[git reset --hard --quiet], pwd: clone_path)
      Shell.run!(%w[git clean -f -d -x], pwd: clone_path)
      Shell.run!(%w[git pull --ff-only --quiet], pwd: clone_path)
    end

    def clone
      Shell.run!(%W[mkdir -p #{store_dir}])
      Shell.run!(%W[git clone --quiet #{uri} #{clone_path}])
      Shell.run!(%W[git checkout #{ref}], pwd: clone_path) if ref
    end

    def store_dir
      File.join(Host.root, 'tmp', 'gouteur_repos')
    end
  end
end
