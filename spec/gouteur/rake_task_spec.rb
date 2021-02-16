require 'gouteur/rake_task'

RSpec.describe 'Gouteur::RakeTask' do
  before(:all) { Gouteur::RakeTask.new }
  after(:each) { Rake::Task[:gouteur].reenable }

  it 'can be invoked' do
    expect(Gouteur::CLI).to receive(:call).with([]) { print 'OK' }.and_return(1)
    expect { Rake::Task[:gouteur].invoke }.to output('OK').to_stdout
  end

  it 'takes URIs as arguments' do
    expect(Gouteur::CLI).to receive(:call).with(%w[foo bar]).and_return(1)
    Rake::Task[:gouteur].invoke('foo', 'bar')
  end
end
