RSpec.describe Gouteur::Bundle do
  let(:bundle) { Gouteur::Bundle.new("#{__dir__}/example_repo") }

  it 'can #install' do
    # stubbed because it's slow
    expect(Open3)
      .to receive(:capture3)
      .with({}, *%w[bundle update --quiet --jobs 4], chdir: bundle.path)
      .and_return(['', '', instance_double(Process::Status, exitstatus: 0)])

    result = bundle.install
    expect(result).to be_a(Gouteur::Shell::Result)
    expect(result).to be_success
  end

  it 'returns true iff #depends_on? is called with dependencies' do
    expect(bundle.depends_on?('rspec')).to eq true
    expect(bundle.depends_on?('my_imaginary_gem')).to eq false
  end

  it 'can #exec' do
    result = bundle.exec('rake dummy')
    expect(result).to be_a(Gouteur::Shell::Result)
    expect(result.stdout).to match 'dummy output'
    stderr_without_deprecations = result.stderr.gsub(/.*deprecat.*\n?/i, '')
    expect(stderr_without_deprecations).to eq ''
    expect(result).to be_success

    result = bundle.exec('my_imaginary_task')
    expect(result).to be_a(Gouteur::Shell::Result)
    expect(result.stdout).to eq ''
    expect(result.stderr).to match /command not found/
    expect(result).not_to be_success
  end
end
