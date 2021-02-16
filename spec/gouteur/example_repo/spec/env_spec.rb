RSpec.describe ExampleRepo do
  it "fails if ENV['FAIL_SPEC_VIA_ENV'] is set" do
    expect(ENV['FAIL_SPEC_VIA_ENV']).to be nil
  end
end
