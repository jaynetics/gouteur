module Gouteur
  # Gemfile of a repository that depends on the library under test
  class Gemfile
    attr_reader :original_path

    def initialize(original_path)
      @original_path = original_path
    end

    def adapted_path
      "#{original_path}.gouteur"
    end

    def content
      File.exist?(original_path) ? File.read(original_path) : ''
    end

    def create_adapted(drop_version_constraint: false)
      adapted_content = self.class.adapt(
        content,
        drop_version_constraint: drop_version_constraint,
      )
      File.open(adapted_path, 'w') { |f| f.puts(adapted_content) }
    end

    def self.adapt(content, drop_version_constraint: false)
      new_entry = "gem '#{Host.name}', path: '#{Host.root}' # set by gouteur "

      existing_ref_pattern =
        /
          ^\s*gem\W+#{Host.name}\W
          (?<version>
            \s*,\s*
            (?:
                #{VERSION_NUMBER_PATTERN}
              |
                \[(?:\s*#{VERSION_NUMBER_PATTERN}\s*,?\s*)+\]
            )
          )?
        /x

      return "#{content}\n#{new_entry}\n" unless content =~ existing_ref_pattern

      content.gsub(existing_ref_pattern) do
        if drop_version_constraint
          new_entry
        else
          # keep version specification if there was one
          new_entry.sub(/(?=, path:)/, Regexp.last_match[:version].to_s)
        end
      end
    end

    VERSION_NUMBER_PATTERN =
      /
          \d+\.\d+ # float
        |
          \d+ # int
        |
          (?:%[qQ]?)?
          (?:
            '[^']+'|"[^"]+"|\[[^\]]+\]|\{[^}]+\}|\([^)]+\)|<[^>]+>
          ) # string literal
      /x.freeze
  end
end
