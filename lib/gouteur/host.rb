module Gouteur
  # the gem/library/project under test
  module Host
    module_function

    def name
      gemspec.name || raise(Error, "No name set in `#{gemspec.loaded_from}`")
    end

    def gemspec
      @gemspec ||= begin
        gemspecs = Dir[File.join(root, '*.gemspec')]
        (count = gemspecs.count) == 1 ||
          raise(Error, "Found #{count} gemspecs, could not determine own name")
        Bundler.load_gemspec(gemspecs.first)
      end
    end

    def root
      Bundler.root
    end
  end
end
