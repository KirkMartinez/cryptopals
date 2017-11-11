require 'spec_helper'
require 'ecb_encryptor'

RSpec.describe ECBEncryptor do
  let(:plain_text) { 'Something Sixish' }

  it 'should return orig when decrypting encrypt' do
    key = 0.chr * 16
    e = ECBEncryptor.new(key)
    encrypted = e.encrypt(plain_text)
    decrypted = e.decrypt(encrypted)
    expect(decrypted).to eq plain_text
  end
end
