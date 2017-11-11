# Challenge 12: byte at a time ECB decryption
#
require_relative 'cbc_encryptor'
require_relative 'ecb_encryptor'
require_relative 'utilities'

KEYSIZE=16

# Oracle encrypts using a consistent, but unknown key with ECB
@key = (1..16).map {rand(256).chr}.join
def encryption_oracle(data)
  plain_text = data

  secret = 'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK'
  plain = secret.unpack("m0").first
  plain_text += plain

  padded = CBCEncryptor.pad(plain_text, KEYSIZE)


  ecb = ECBEncryptor.new(@key)
  ecb.encrypt(padded)
end

# Now we can determine secret by passing our own text
# First, what is the block size?
size = encryption_oracle('a').length
(2..40).each do |s|
  r = 'a'*s
  encrypted = encryption_oracle(r)
  if encrypted.length != size
    puts "Block size: #{encrypted.length - size}"
    break
  end
end

# 16 bytes, right.
# Now detect ECB: repeated plaintext yields repeated ciphertext
r = 'a'*64
(1..10).each do |try|
  enc = encryption_oracle(r)
  if repeats(enc)
    puts "Looks like ECB"
    break
  else
    puts "Not ECB..."
  end
end

# Now craft a block 1 byte short of the block length
# oracle/alg is going to fill with first digit of unknown string
# For example, 15 bytes of 'a' will be followed by the first unknown char
# plain text          unknown bits
# aaaaaaaaaaaaaaaG    OT IT ALL DECRYPTED.

# Given:
#   r: string with N bytes of dummy chars, where N < BLOCKSIZE
#   so_far: the found unknown chars, len(so_far)+len(r)%16 == BLOCKSIZE-1
#   block_num: which block to decrypt
def decrypt(prefix_count, so_far, block_num)
  r = 'a'*prefix_count
  # puts "Decrypt; prefix_count: #{prefix_count} (#{r.length}) so_far: #{so_far} (#{so_far.length}) block_num: #{block_num}"
  #raise unless (r.length + so_far.length) % 16 == 15
  short = encryption_oracle(r)[block_num*16..block_num*16+15] # ciphertext with start of unknown
  # ^ pulling the right byte, but need to include 15 bytes of of padding...

  (0..255).each do |ch|
    if block_num == 0
      t = r + so_far + ch.chr # padding + known unknown chars + test char in last position
    else
      t = so_far + ch.chr # no padding since we are in scan mode Now
    end
    test = encryption_oracle(t)[0..15]
    if short == test
      return ch
    end
  end
  nil
end

# We can create 256 encryptions of 15 a's and find the matching ciphertext
# aaaaaaaaaaaaaaa?    Whichever one matches identifies ? == 1st char of unknown

# So say we find the 1st byte: 'G', then the alg is effectively encrypting:
# plain text          unknown bits
# aaaaaaaaaaaaaaaG    OT IT ALL DECRYPTED.

# So, now we remove another 'a' and add the known 'G' to get the next byte:
# plain text          unknown bits
# aaaaaaaaaaaaaaGO    T IT ALL DECRYPTED.

def decrypt_block
  pt_so_far = ''
  # Let's do 16 bytes worth:
  (0..1000).each do |byte|
    block_num = byte / 16 # Block including char we are identifying
    if byte < 16
      pos_to_insert = 16-byte
      prefix_count = (pos_to_insert-1)
      decrypted_char = decrypt(prefix_count, pt_so_far, block_num)
      pt_so_far += decrypted_char.chr
      # puts pt_so_far
    else
      # byte 16 means pad 15, compare 0..15 vs byte block_num
      # byte 31 means pad 0
      pt_so_far = pt_so_far[1..15]
      decrypted_char = decrypt(15-byte%16, pt_so_far, block_num)
      break unless decrypted_char
      pt_so_far += decrypted_char.chr
      # puts pt_so_far
    end
    print(decrypted_char.chr)
  end
end

decrypt_block

# Once we have a byte's worth:
# plain text (16)     unknown bits
# GOT IT ALL DECRY    PTED.

# We can formulate 16 bytes with the missing next byte:
# plain text (16)     unknown bits
# OT IT ALL DECRY?    TED.
# which needs to be matched against the original shifted:
# plain text (16)     unknown 1st 16 bytes    unknown 2nd 16 bytes
# aaaaaaaaaaaaaaaG    OT IT ALL DECRY?        PTED.
#                                    ^
#                                    |
#                                    +- find this char

# This technique works to decrypt the rest of the unknown text.
