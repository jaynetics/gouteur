module Gouteur
  # interface for gouteur's configuration dotfile
  module Dotfile
    module_function

    def path
      File.join(Host.root, '.gouteur.yml')
    end

    def content
      @content ||=
        File.exist?(path) ? YAML.load_file(path, symbolize_names: true) : {}
    end

    def repos
      (content[:repos] || []).map { |attrs| Gouteur::Repo.new(**attrs) }
    end
  end
end
