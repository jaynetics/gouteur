RSpec.describe Gouteur::Checker do
  let(:checker) { Gouteur::Checker.new(repo, silent: true) }
  let(:repo) { Gouteur::Repo.new(uri: "#{__dir__}/example_repo") }

  # stubs origin as path so we don't need to clone and bundle the repo
  def stub_repo_preparation!
    allow(repo.bundle).to receive(:path).and_return(repo.uri.to_s)
  end

  describe '#prepare' do
    it 'fails if called with an inexistent repo' do
      repo = Gouteur::Repo.new(uri: './inexistent_uri')
      checker = Gouteur::Checker.new(repo)
      expect { checker.prepare }.to raise_error(Gouteur::Error, /git clone/)
    end

    it 'fails if bundling fails' do
      repo = Gouteur::Repo.new(uri: './some_gem')
      checker = Gouteur::Checker.new(repo)
      expect(repo).to receive(:fetch).and_return(true)
      expect { checker.prepare }.to raise_error(Gouteur::Error, /bundle update/)
    end
  end

  describe '#check_dependence' do
    it 'succeeds for actual dependencies' do
      stub_repo_preparation!
      expect { checker.check_dependence }.not_to raise_error
    end

    it 'fails if called with an unrelated repo' do
      repo = Gouteur::Repo.new(uri: './some_unrelated_gem')
      checker = Gouteur::Checker.new(repo)
      expect { checker.check_dependence }
        .to raise_error(Gouteur::Error, /not .*in .*Gemfile or gemspec/)
    end
  end

  describe '#run_tasks' do
    it 'fails if there are no tasks' do
      expect(repo).to receive(:tasks).and_return([])
      expect { checker.run_tasks }.to raise_error(Gouteur::Error, /no task/)
    end

    it 'runs all repo tasks' do
      stub_repo_preparation!
      # this actually runs the default rake task (rspec), so takes a second
      expect { checker.run_tasks }.not_to raise_error
    end
  end

  let(:adapted_gemfile) { "#{__dir__}/example_repo/Gemfile.gouteur" }

  def write_adapted_gemfile(content)
    File.write(adapted_gemfile, "source 'https://rubygems.org'\n\n#{content}")
  end

  describe '#create_adapted_gemfile' do
    it 'creates a gemfile referencing the local copy' do
      stub_repo_preparation!
      `rm -f #{adapted_gemfile}` if File.exist?(adapted_gemfile)

      expect { checker.create_adapted_gemfile }
        .to change { File.exist?(adapted_gemfile) }.to(true)

      content = File.read(adapted_gemfile)
      expect(content).to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      # there should be only on mention
      expect(content.scan(/^gem *["']gouteur["']/).count).to eq 1
    end
  end

  describe '#install_adapted_bundle' do
    it 'installs the bundle from the adapted gemfile' do
      stub_repo_preparation!

      # this is very slow with a real gem download,
      # but at the heart of the gem, so should be tested
      write_adapted_gemfile("gem 'sexy_slug'")

      expect(checker.install_adapted_bundle).to eq true
      expect(File.read("#{adapted_gemfile}.lock")).to include 'sexy_slug'
    end

    it 'returns false if the current gem version is incompatible' do
      stub_repo_preparation!

      write_adapted_gemfile("gem 'gouteur', '1337', path: '../../../'")

      expect(checker.install_adapted_bundle).to eq false
    end

    it 'can raise if the installation fails for other reasons' do
      stub_repo_preparation!

      write_adapted_gemfile('nonsense')

      expect { checker.install_adapted_bundle }.to raise_error(Gouteur::Error)
    end
  end

  describe '#adapt_gemfile_content' do
    it 'surely works without a parser for every case there is in the world' do
      adapt = ->(content) { checker.adapt_gemfile_content(content) }

      expect(adapt[%()])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'other')])
        .to match %r{gem 'other'\ngem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur')])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur' # cool!)])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', '1.2-pre')])
        .to match %r{^gem 'gouteur', '1\.2-pre', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', '1.2' # cool!)])
        .to match %r{^gem 'gouteur', '1\.2', path: '/.+ # set by gouteur}

      expect(adapt[%(gem "gouteur",\n"1.2")])
        .to match %r{^gem 'gouteur',\n"1\.2", path: '/.+ # set by gouteur}
    end
  end

  describe '#run_task' do
    it 'runs the task with #adaptation_env iff adapted: true' do
      stub_repo_preparation!

      expect { checker.run_task('rspec spec/env_spec.rb') }
        .not_to raise_error

      expect { checker.run_task('rspec inexistent_spec.rb') }
        .to raise_error(Gouteur::Error, /`rspec inexistent_spec.rb` failed/)

      evil_env = { 'FAIL_SPEC_VIA_ENV' => '1' }
      expect(checker).to receive(:adaptation_env).and_return(evil_env)
      expect { checker.run_task('rspec spec/env_spec.rb', adapted: true) }
        .to raise_error(Gouteur::Error, %r{`rspec spec/env_spec.rb` failed})
    end

    it 'outputs to stdout if not silent' do
      stub_repo_preparation!

      expect { Gouteur::Checker.new(repo).run_task('rspec spec/env_spec.rb') }
        .to output(/Running.*rspec/).to_stdout
    end
  end

  describe '#adaptation_env' do
    it 'makes tasks use the adapted gemfile' do
      stub_repo_preparation!

      expect { checker.run_task('rspec') }.not_to raise_error

      write_adapted_gemfile("gem 'i_dont_exist'")

      expect { checker.run_task('rspec', adapted: true) }
        .to raise_error(Gouteur::Error, /i_dont_exist/)
    end
  end

  describe '#handle_incompatible_semver' do
    it 'treats incompatible versions as success by default' do
      result = checker.handle_incompatible_semver
      expect(result[0]).to eq true
      expect(result[1]).to match(/incompatible/)
    end

    it 'raises if the repo is #locked?' do
      expect(repo).to receive(:locked?).and_return(true)
      expect { checker.handle_incompatible_semver }.to raise_error(Gouteur::Error)
    end
  end
end
