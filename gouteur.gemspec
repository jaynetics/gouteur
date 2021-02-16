require_relative 'lib/gouteur/version'

Gem::Specification.new do |spec|
  spec.name          = 'gouteur'
  spec.version       = Gouteur::VERSION
  spec.authors       = ['Janosch Müller']
  spec.email         = ['janosch84@gmail.com']

  spec.summary       = 'See if your lib is still digestible.'
  spec.description   = 'Run tests of dependent gems against your changes.'
  spec.homepage      = 'https://github.com/jaynetics/gouteur'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jaynetics/gouteur'
  spec.metadata['changelog_uri'] =
    'https://github.com/jaynetics/gouteur/blob/master/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = ['gouteur']
  spec.require_paths = ['lib']
end
