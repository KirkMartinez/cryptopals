# Challenge 10: implement CBC using ECB
require_relative 'file_reader'
require_relative 'blockifier'
require_relative 'xor_encryptor'
require_relative 'ecb_encryptor'
require_relative 'cbc_encryptor'

KEYSIZE=16
key = 'YELLOW SUBMARINE'
# xor iv will not change input, so just skip xor carry for 0th block
iv = 0.chr * 16

(c_64, c_raw, c_hex) = FileReader.load('10.txt')
padded = CBCEncryptor.pad(c_64, KEYSIZE)

# Break into 16 byte blocks
blocks = Blockifier.split(c_raw, KEYSIZE)

# Decrypt file
ecb_encryptor = ECBEncryptor.new(key)
dec_blocks = []
carry = iv
blocks.each do |block|
  decrypted_block = ecb_encryptor.decrypt(block)
  xored = XorEncryptor.xor_raw(decrypted_block, carry)
  dec_blocks.push(xored)
  carry = block
end

puts dec_blocks.join
