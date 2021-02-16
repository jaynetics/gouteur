RSpec.describe Gouteur::Host do
  describe '#name' do
    it 'returns the name of the host gem (the library under test)' do
      expect(Gouteur::Host.name).to eq 'gouteur'
    end
  end
end
