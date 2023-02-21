RSpec.describe Gouteur::Gemfile do
  let(:repo) { Gouteur::Repo.new(uri: "#{__dir__}/example_repo") }
  let(:adapted_gemfile) { "#{__dir__}/example_repo/Gemfile.gouteur" }

  before { allow(repo.bundle).to receive(:path).and_return(repo.uri) }

  describe '#create_adapted' do
    it 'creates a gemfile referencing the local copy' do
      `rm -f #{adapted_gemfile}` if File.exist?(adapted_gemfile)

      expect { repo.gemfile.create_adapted }
        .to change { File.exist?(adapted_gemfile) }.to(true)

      content = File.read(adapted_gemfile)
      expect(content).to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      # there should be only on mention
      expect(content.scan(/^gem *["']gouteur["']/).count).to eq 1
    end
  end

  describe '::adapt' do
    it 'surely works without a parser for every case there is in the world' do
      adapt = ->(*args, **kwargs) { Gouteur::Gemfile.adapt(*args, **kwargs) }

      # can change path
      expect(adapt[%()])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'other')])
        .to match %r{gem 'other'\ngem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur')])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur' # cool!)])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', path: 'X' # already has a path!)])
        .to match %r{^gem 'gouteur', path: '/[^X][^:]+ # set by gouteur}

      # keeps version constraints in various formats
      expect(adapt[%(gem 'gouteur', '1.2')])
        .to match %r{^gem 'gouteur', '1\.2', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', "1.2")])
        .to match %r{^gem 'gouteur', "1\.2", path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', %(1.2))])
        .to match %r{^gem 'gouteur', %\(1\.2\), path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', %q<1.2>)])
        .to match %r{^gem 'gouteur', %q<1\.2>, path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', '1.2-pre')])
        .to match %r{^gem 'gouteur', '1\.2-pre', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', '1.2' # cool!)])
        .to match %r{^gem 'gouteur', '1\.2', path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', 1.2)])
        .to match %r{^gem 'gouteur', 1\.2, path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', 12)])
        .to match %r{^gem 'gouteur', 12, path: '/.+ # set by gouteur}

      expect(adapt[%(gem 'gouteur', [">= 1.2", "< 10.0"])])
        .to match %r{^gem 'gouteur', \[">= 1.2", "< 10.0"\], path: '/.+ # set by gouteur}

      expect(adapt[%(gem "gouteur",\n"1.2")])
        .to match %r{^gem 'gouteur',\n"1\.2", path: '/.+ # set by gouteur}

      # can remove version constraints
      expect(adapt[%(gem 'gouteur', '1.2'), drop_version_constraint: true])
        .to match %r{^gem 'gouteur', path: '/.+ # set by gouteur}
    end
  end
end
