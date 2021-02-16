module Gouteur
  # interface for gouteur's configuration dotfile
  module Dotfile
    module_function

    def present?
      File.exist?(path)
    end

    def path
      File.join(Host.root, '.gouteur.yml')
    end

    def content
      @content ||=
        present? ? YAML.safe_load(File.read(path), symbolize_names: true) : {}
    end

    def repos
      (content[:repos] || []).map { |attrs| Gouteur::Repo.new(**attrs) }
    end
  end
end
