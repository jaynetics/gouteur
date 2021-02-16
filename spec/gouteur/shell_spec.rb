RSpec.describe Gouteur::Shell do
  describe '#run' do
    it 'returns a positive result if successful' do
      result = Gouteur::Shell.run(%w[echo 123])
      expect(result).to be_success
      expect(result.stdout).to match '123'
      expect(result.stderr).to be_empty
    end

    it 'returns a negative result if not successful' do
      result = Gouteur::Shell.run(%w[my_imaginary_command])
      expect(result).not_to be_success
      expect(result.stderr).to include 'my_imaginary_command'
    end
  end

  describe '#run!' do
    it 'returns a positive result if successful' do
      result = Gouteur::Shell.run!(%w[echo 123])
      expect(result).to be_success
      expect(result.stdout).to match '123'
      expect(result.stderr).to be_empty
    end

    it 'raises if not successful' do
      expect { Gouteur::Shell.run!(%w[my_imaginary_command]) }
        .to raise_error(Gouteur::Error, /my_imaginary_command/)
    end
  end
end
