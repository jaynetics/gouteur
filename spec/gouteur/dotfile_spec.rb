RSpec.describe Gouteur::Dotfile do
  describe '::repos' do
    it 'returns an Array of Gouteur::Repos' do
      result = Gouteur::Dotfile.repos
      expect(result.count).to eq 1
      expect(result.first).to be_a Gouteur::Repo
      expect(result.first.uri).to eq 'example_uri_in_dotfile'
    end
  end
end
