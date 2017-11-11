# Challenge 6: break repeating key xor
$LOAD_PATH.unshift(File.expand_path('.'))

require 'xor_decoder'
require 'xor_encryptor'

# Input: two raw strings
# Output: # of different bits
def hamming_dist(s1, s2)
    d = 0
    cs1 = s1.unpack('C*')
    cs2 = s2.unpack('C*')
    cs1.zip(cs2).each do |c1, c2|
        c1 = 0 if !c1
        c2 = 0 if !c2
        diff = c1 ^ c2
        d += bits_on(diff)
    end
    d
end

def bits_on(i)
    bits = 0
    while i > 0
        bits += 1 if i % 2 ==1
        i /= 2
    end
    bits
end

raise "Hamming distance broken" unless hamming_dist('this is a test', 'wokka wokka!!!') == 37

# Ciphertext
ciphertext_64 = File.open('../data/6.txt', 'rb').read().gsub(/\r/,'').gsub(/\n/,'')
ciphertext_raw = ciphertext_64.unpack("m0").first
ciphertext_hex = ciphertext_raw.unpack('H*').first

# puts "First 10 bytes"
# puts "base64: #{ciphertext_64[0..9]}"
# puts "raw: #{ciphertext_raw[0..9]}"
# puts "hex: #{ciphertext_hex[0..19]}"

# Determine most likely keysizes
NUM_KEYSIZE_CANDIDATES = 1

# Likely keysize is smallest normalized average distance between
# sequential keysize-blocks
score = []
(2..40).each do |keysize|
  reps = ciphertext_raw.length / keysize
  blk_score = 0
  (0..reps-1).each do |blk|
    offset = blk * keysize
    b1 = ciphertext_raw[offset+0..offset+keysize-1]
    b2 = ciphertext_raw[offset+keysize..offset+2*keysize-1]
    d12 = hamming_dist(b1, b2)
    blk_score += Float(d12)/keysize
  end
  score.push [keysize, blk_score / reps]
end

score.sort! { |x,y| x[1] <=> y[1] }

keysize_candidates = score[0..NUM_KEYSIZE_CANDIDATES-1].map { |x| x[0] }
puts "Keysize looks like: #{keysize_candidates[0]}"

keysize_candidates.each do |keysize|
  puts "Breaking ciphertext into #{keysize} blocks..."
  key = []
  # Reformat ciphertext into keysize blocks where block N is
  # the Nth byte of each ciphertext block
  blocks = []
  (0..keysize-1).each do |k|
    # WARNING: scan will drop the last N < keysize elements
    # BIGGER WARNING: regexp . doesn't match all bytes
    # blocks[k] = ciphertext_raw.scan(/.{#{keysize}}/).map {|x| x[k]}.join
    blocks[k] = ciphertext_raw.chars.each_slice(keysize).to_a.map {|x| x[k]}.join
  end

  puts "Decrypting blocks to break key..."
  # decrypt each block with single-byte xor
  x = 0
  blocks.each do |block|
    block_hex = block.unpack('H*').first
    x+=1
    (score, key_char, decoded) = XorDecoder.xor_decode(block_hex)
    key.push(key_char)
    print key_char.chr
  end
  puts "."
  key = key.pack("C*")
  puts "\nTry decrypt with key: #{key}..."

  decryptor = XorEncryptor.new(key)
  puts "Decrypt: #{[decryptor.encode(ciphertext_hex)].pack('H*')}"
end
