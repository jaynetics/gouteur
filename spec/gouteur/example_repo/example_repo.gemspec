require_relative 'lib/example_repo/version'

Gem::Specification.new do |spec|
  spec.name          = 'example_repo'
  spec.version       = ExampleRepo::VERSION
  spec.authors       = ['Janosch Müller']
  spec.email         = ['janosch84@gmail.com']

  spec.summary       = 'This is for testing; not intended for publication'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end
  spec.require_paths = ['lib']
end
