require_relative 'blockifier'
require_relative 'ecb_encryptor'
require_relative 'xor_encryptor'

BLOCKSIZE=16

class CBCEncryptor
  def initialize(key)
    @ecb_encryptor = ECBEncryptor.new(key)
    @key = key
    @keysize = key.length
  end

  # Input: some text
  # Output given text PKCS7-padded to a multiple of the key length
  def self.pad(text, key_length)
    if text.length < key_length
      size = key_length
    else
      if text.length % key_length == 0
        size = text.length + key_length # Need zero bytes to indicate end
      else
        size = text.length + key_length - (text.length % key_length)
      end
    end
    bytes = size - text.length
    result = text
    result + (bytes.chr * bytes)
  end

  def encrypt(text, iv)
    blocks = Blockifier.split(text, @keysize)
    self.encrypt_blocks(blocks, iv).join
  end

  # CBC encrypt
  def encrypt_blocks(blocks, iv)
    # xor iv/prior with plaintext block, encrypt with ecb, next
    enc_blocks = []
    carry = iv
    blocks.each do |block|
      # This ends up causing PT to be prefixed with \x00s
      # since ecb padding == 0, but setting padding on decrypt does not work
      # if block.length < BLOCKSIZE
      #   block = CBCEncryptor.pad(block, BLOCKSIZE)
      # end
      # puts "Block size: #{block.length}"
      xored = XorEncryptor.xor_raw(block, carry)
      #puts "Xored len: #{xored.length}"
      encrypted_block = @ecb_encryptor.encrypt(xored)
      # puts "Enc block size: #{encrypted_block.length}"

      enc_blocks.push(encrypted_block)
      carry = encrypted_block
    end
    return enc_blocks
  end

  def decrypt(text, iv)
    blocks = Blockifier.split(text, @keysize)
    self.decrypt_blocks(blocks, iv).join
  end

  # CBC decrypt
  def decrypt_blocks(blocks, iv)
    dec_blocks = []
    carry = iv
    blocks.each do |block|
      decrypted_block = @ecb_encryptor.decrypt(block)
      xored = XorEncryptor.xor_raw(decrypted_block, carry)
      dec_blocks.push(xored)
      carry = block
    end
    return dec_blocks
  end
end
