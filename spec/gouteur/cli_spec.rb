RSpec.describe Gouteur::CLI do
  let(:repo) { Gouteur::Repo.new(uri: 'foobar') }

  describe '::call' do
    it 'returns true if all Checkers succeed' do
      expect(Gouteur::CLI).to receive(:pick_repos).and_return([repo, repo])
      expect(Gouteur::Checker).to receive(:call) do |arg|
        expect(arg).to eq repo
      end.twice.and_return([true, 'success_message'])
      expect do
        expect(Gouteur::CLI.call(['foo'])).to eq true
      end.to output(/success_message/).to_stdout
    end

    it 'warns and returns false if a Checker fails' do
      expect(Gouteur::CLI).to receive(:pick_repos).and_return([repo])
      expect(Gouteur::Checker).to receive(:call)
        .and_return([false, 'error_message'])
      expect do
        expect(Gouteur::CLI.call([])).to eq false
      end.to output(/error_message/).to_stdout
    end

    it 'warns and returns false if there are no repos' do
      expect(Gouteur::CLI).to receive(:pick_repos).and_return([])
      expect do
        expect(Gouteur::CLI.call([])).to eq false
      end.to output(/no repo/).to_stdout
    end
  end

  describe '::pick_repos' do
    it 'uses URIs from ARGV' do
      result = Gouteur::CLI.pick_repos(['uri_123'])
      expect(result.count).to eq 1
      expect(result.first).to be_a Gouteur::Repo
      expect(result.first.uri.to_s).to eq 'uri_123'
    end

    it 'falls back to repos defined in the dotfile' do
      expect(Gouteur::Dotfile).to receive(:repos).and_return(:repos_stub)
      expect(Gouteur::CLI.pick_repos([])).to eq :repos_stub
    end
  end
end
