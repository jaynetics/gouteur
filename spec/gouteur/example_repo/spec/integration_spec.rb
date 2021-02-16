RSpec.describe 'With bundled gouteur' do
  it 'determines the correct host gem name' do
    expect(Gouteur::Host.name).to eq 'example_repo'
  end

  it 'uses the correct dotfile' do
    expect(Gouteur::Dotfile.repos.count).to eq 1
    expect(Gouteur::Dotfile.repos.first.uri.to_s).to eq 'uri_in_nested_dotfile'
  end
end
