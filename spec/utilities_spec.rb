require 'utilities'

RSpec.describe 'utilities' do
  let(:plain_text) { 'Something Sixish' }

  it 'repeats returns true when bytes repeat' do
    expect(repeats(plain_text*2, 16)).to be true
  end
end
