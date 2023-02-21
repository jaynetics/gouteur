RSpec.describe Gouteur::Repo do
  let(:repo) { Gouteur::Repo.new(uri: "#{__dir__}/example_repo") }

  it 'has a #uri' do
    # String, not URI, because git SSH addresses are not valid URLs,
    # c.f. https://stackoverflow.com/a/70330178
    expect(repo.uri).to be_a String
  end

  it 'extracts a #name from the uri, or can have a custom name' do
    expect(repo.name).to eq 'example_repo'

    github_repo = Gouteur::Repo.new(uri: 'https://github.com/user/project')
    expect(github_repo.name).to eq 'project'

    gitlab_repo = Gouteur::Repo.new(uri: 'https://gitlab.com/user/project')
    expect(gitlab_repo.name).to eq 'project'

    non_github_repo = Gouteur::Repo.new(uri: 'https://foo.com/bar?baz=123')
    expect(non_github_repo.name).to eq 'bar'

    named_repo = Gouteur::Repo.new(name: 'cool', uri: 'https://x.y/z')
    expect(named_repo.name).to eq 'cool'

    expect { Gouteur::Repo.new(uri: '') }.to raise_error(Gouteur::Error, /name/)
  end

  it 'can have a #ref' do
    expect(repo.ref).to be_nil
    repo = Gouteur::Repo.new(uri: './repo', ref: 'origin/develop')
    expect(repo.ref).to eq 'origin/develop'
  end

  it 'has a default #task' do
    expect(repo.tasks).to eq ['rake']
  end

  it 'can have other #tasks' do
    repo = Gouteur::Repo.new(uri: './repo', tasks: %w[build rspec])
    expect(repo.tasks).to eq %w[build rspec]
  end

  it 'can be set to #locked?' do
    expect(repo.locked?).to eq false
    repo = Gouteur::Repo.new(uri: './repo', locked: true)
    expect(repo.locked?).to eq true
  end

  it 'has a #clone_path' do
    expect(repo.clone_path).to match %r{gouteur_repos/example_repo$}
  end

  it 'can #fetch and #remove the repo' do
    # sub-repo is not checked in with main repo, make sure it exists
    Dir.chdir(repo.uri) do
      File.exist?("#{repo.uri}/.git") || `git init`
      `git add . && git commit -am 🚀`
    end

    cloned_gemfile = "#{repo.clone_path}/Gemfile"

    expect { repo.fetch }.to change { File.exist?(cloned_gemfile) }.to(true)
    expect { repo.fetch }.not_to change { File.exist?(cloned_gemfile) }
    expect { repo.remove }.to change { File.exist?(cloned_gemfile) }.to(false)
  end
end
