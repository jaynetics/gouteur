# 👨‍🍳 Gouteur

[![Gem Version](https://badge.fury.io/rb/gouteur.svg)](http://badge.fury.io/rb/gouteur)
[![Build Status](https://github.com/jaynetics/gouteur/workflows/build/badge.svg)](https://github.com/jaynetics/gouteur/actions)

Treat the people that use your gem like royalty! Send for a [gouteur](https://en.wikipedia.org/wiki/Food_taster) before serving them something new!

## What?

This gem runs the build tasks of other projects against your unreleased changes.

## Why?

Sometimes, other projects start depending on your gem.

When you release a new version of your gem, these projects might break.

[Semantic versioning](https://semver.org) obviously helps. People make mistakes, though. The boundary between public and private APIs can also be fuzzy, particularly in an open language like Ruby.

Thus, when you update your gem, you might feel as if you should check whether things that depend on it will keep working before you release the new version.

Gouteur automates this step.

## Installation

Add `gouteur` to the development dependencies of your gem.

## Usage

### Recommended usage

Create a `.gouteur.yml` in the root of your project:

```yml
repos:
  - uri: https://github.com/someone/some_gem
    ref: some_specific_branch # optional, default is the default branch
    before: setup_special_dependency # optional, bundle is always installed
    tasks: ['rspec', 'rake foo'] # optional, default is `rake`
    name: cool_gem # optional, defaults to repo name from uri, e.g. `some_gem`
    locked: true # optional, prevents setting an incompatible VERSION
    force: true # optional, forces test even if VERSION is incompatible
```

Then simply `bundle exec gouteur` or add the rake task to your Rakefile:

```ruby
require 'gouteur/rake_task'
Gouteur::RakeTask.new

# default name is :gouteur, e.g. to include it in the default task:
task default: %i[rspec gouteur]
```

Pro tip: for large repos, running only relevant specs can speed up things a lot, e.g.:

```yml
tasks: 'rspec spec/known_relevant_spec.rb'
```
```yml
tasks: 'rspec --pattern "**/{,*}{keyword1,keyword2}{,*,*/**/*}_spec.rb"'`
```

### Manual usage

From the shell:

```shell
# example: check one dependent repo
gouteur 'https://github.com/foo/bar'

# see other usage options:
gouteur --help
```

From Ruby:

```ruby
repo = Gouteur::Repo.new(uri: 'https://github.com/foo/bar')
success, message = Gouteur::Checker.call(repo)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaynetics/gouteur.

## Outlook

Possible future improvements:

- consider caching of dependent repositories in CI, e.g. in GitHub workflows
- support more sources of code, e.g. latest release, private GitHub repositories
- improve performance by tracing & rerunning only specs/tests that use the gem
- save time in MiniTest by forcing it to run in fail-fast mode like RSpec
- other ideas? open an issue!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
