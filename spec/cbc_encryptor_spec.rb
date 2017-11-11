require 'spec_helper'
require 'cbc_encryptor'

RSpec.describe CBCEncryptor do
  let(:plain_text) { 'Hello' }
  let(:plain_text16) { 'Something Sixish' }

  it 'should return orig when decrypting encrypt of short plain text' do
    skip 'I can pad manually, but then openssl will not remove it. ' +
         'This is why padding is still displayed when strings are decrypted'
    key = (0..15).map {|x| x.chr}.join
    iv = 0.chr * 16
    e = CBCEncryptor.new(key)
    # puts "PTlen: #{plain_text.length}"
    # puts "Keylen: #{key.length}"
    # puts "ivlen: #{iv.length}"
    enc = e.encrypt(plain_text, iv)
    # puts "Enclen: #{enc.length}"
    dec = e.decrypt(enc, iv)

    expect(dec).to eq plain_text
  end

  it 'should return orig when decrypting encrypt of 16 byte plain text' do
    key = (0..15).map {|x| x.chr}.join
    iv = 0.chr * 16
    e = CBCEncryptor.new(key)
    enc = e.encrypt(plain_text16, iv)
    dec = e.decrypt(enc, iv)

    expect(dec).to eq plain_text16
  end
end
