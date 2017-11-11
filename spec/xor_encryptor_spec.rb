require 'spec_helper'
require 'xor_encryptor'

RSpec.describe XorEncryptor do
  describe '.xor_hex' do
    context 'with challenge 2 data' do
      # From challenge 2
      let(:plain_text) { '1c0111001f010100061a024b53535009181c' }
      let(:key) { '686974207468652062756c6c277320657965' }
      let(:expected) { '746865206b696420646f6e277420706c6179' }

      it 'should work using hex data' do
        expect(XorEncryptor.xor_hex(plain_text, key)).to eq(expected)
      end

      it 'should work using hex data' do
        raw_plain_text = [plain_text].pack('H*')
        raw_key = [key].pack('H*')
        raw_exptected = [expected].pack('H*')
        raw_xored = XorEncryptor.xor_raw(raw_plain_text, raw_key)
        xored = raw_xored.unpack('H*').first
        expect(xored).to eq(expected)
      end
    end
  end
end
