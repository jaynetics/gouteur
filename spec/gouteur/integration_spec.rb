#
# This spec is a bit special:
# It runs a spec of the example_repo within the bundle of that repo,
# to ensure that Gouteur acts correctly when part of another bundle.
# The actual expectations are in the executed spec.
#
RSpec.describe 'Integration' do
  it 'works' do
    output = Dir.chdir("#{__dir__}/example_repo") do
      Bundler.with_original_env { `bundle exec rspec spec/integration_spec.rb` }
    end
    expect(output).to include ' 0 failures'
  end
end
