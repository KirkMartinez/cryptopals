module XorDecoder

    def self.FREQ
        {
        ' '=> 5,
        'A'=> 8.34,
        'B'=> 1.54,
        'C'=> 2.73,
        'D'=> 4.14,
        'E'=> 12.60,
        'F'=> 2.03,
        'G'=> 1.92,
        'H'=> 6.11,
        'I'=> 6.71,
        'J'=> 0.23,
        'K'=> 0.87,
        'L'=> 4.24,
        'M'=> 2.53,
        'N'=> 6.80,
        'O'=> 7.70,
        'P'=> 1.66,
        'Q'=> 0.09,
        'R'=> 5.68,
        'S'=> 6.11,
        'T'=> 9.37,
        'U'=> 2.85,
        'V'=> 1.06,
        'W'=> 2.34,
        'X'=> 0.20,
        'Y'=> 2.04,
        'Z'=> 0.06
        }
    end

    # Input: string of characters
    # Output: sum_over_letters(the letter's frequency)
    def self.score(s)
        result = 0
        s.chars.each do |c|
            f = self.FREQ[c.upcase()]
            result += f if f
        end
        result
    end

    def self.two_digit_hex(byte)
        return "0#{byte.to_s(16)}" unless byte > 15
        byte.to_s(16)
    end

    # Input: ciphertext as string of hex bytes
    # Output: [score (float), key (int), plaintext (hex string)]
    def self.xor_decode(cyphertext)
        i_int = cyphertext.to_i(16)
        results = []
        (0..255).each do |key|
            extended_key = (two_digit_hex(key) * (cyphertext.length / 2))
            extended_key_i = extended_key.to_i(16)
            decode_int = i_int ^ extended_key_i
            decoded = [decode_int.to_s(16)].pack('H*')
            decoded = "0#{decoded}" if decoded.length % 2 > 0
            sc = score(decoded)
            results.push( [sc, key, decoded] )
        end

        # show_histogram(results)

        results.sort! { |x,y| y[0] <=> x[0]}
        return [results[0][0], results[0][1], results[0][2]]
    end

    def self.show_histogram(results)
      puts "\n"
      results.each do |r|
        if r[0] > 1
          puts "Key: #{r[1]} #{'*'*(r[0]/10)}"
        end
      end
      puts "\n"
    end

end
