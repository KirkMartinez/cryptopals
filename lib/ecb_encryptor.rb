require 'openssl'

class ECBEncryptor
  def initialize(key_raw)
    @key = key_raw
  end

  def decrypt(s_raw)
    cipher = OpenSSL::Cipher.new('AES-128-ECB')
    cipher.padding = 0
    cipher.decrypt
    cipher.key = @key

    return cipher.update(s_raw) + cipher.final
  end

  def encrypt(s_raw)
    cipher = OpenSSL::Cipher.new('AES-128-ECB')
    cipher.padding = 0
    cipher.encrypt
    cipher.key = @key

    return cipher.update(s_raw) + cipher.final
  end
end
