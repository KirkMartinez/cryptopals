require 'spec_helper'
require 'blockifier'

describe Blockifier do
  let(:text) { 'AAAABBBBDD' }
  it 'should split into blocks based on given size' do
    blocks = described_class.split(text, 4)
    expect(blocks.length).to eq(3)
    expect(blocks[0].length).to eq(4)
    expect(blocks[1].length).to eq(4)
    expect(blocks[2].length).to eq(2)
  end
end
