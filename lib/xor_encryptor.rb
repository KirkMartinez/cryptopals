class XorEncryptor
    def initialize(key)
        @key = key.unpack('C*').map {|c| XorEncryptor.two_digit_hex(c)}.join
        puts "Encrypting with key: #{@key}"
        @keylen = @key.length
    end

    # Input: raw data as a hex string
    # Output: encrypted data as a hex string
    def encode(s)
        len = s.length
        key_repeats = len / @keylen
        extended_key = @key * key_repeats
        if len % @keylen > 0
            partial_key = len % @keylen
            extended_key += @key[0..partial_key-1]
        end

        return XorEncryptor.xor_hex(s, extended_key)
        # xored = s.to_i(16) ^ extended_key.to_i(16)
        # decrypt = xored.to_s(16)
        # decrypt = "0#{decrypt}" if decrypt.length % 2 > 0 # hacky...
        # decrypt
    end

    # xor two hex-encoded strings, return hex string
    def self.xor_hex(a, b)
      xored = a.to_i(16) ^ b.to_i(16)
      decrypt = xored.to_s(16)
      # Leading zeros will be dropped, so put them back...
      num_missing_zeros = [a.length, b.length].max - decrypt.length
      return '0'*num_missing_zeros + decrypt
    end

    # xor two raw strings, return raw string
    def self.xor_raw(a, b)
      a_hex = a.unpack('H*').first
      b_hex = b.unpack('H*').first
      return [self.xor_hex(a_hex, b_hex)].pack('H*')
    end

    def self.two_digit_hex(byte)
        return "0#{byte.to_s(16)}" unless byte > 15
        byte.to_s(16)
    end
end
