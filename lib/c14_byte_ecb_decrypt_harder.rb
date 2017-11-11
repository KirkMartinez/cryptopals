# Challenge 14: byte at a time ECB decryption
require_relative 'cbc_encryptor'
require_relative 'ecb_encryptor'
require_relative 'utilities'

KEYSIZE=16

# Oracle encrypts using a consistent, but unknown key with ECB
# Oracle encrypts like this:
#   AES-128-ECB(random-prefix || attacker-controlled || target-bytes, random-key)
@key = (1..KEYSIZE).map {rand(256).chr}.join
def encryption_oracle(attacker_controlled)
  rnd = rand(40)
  random_prefix = (0..rnd).map { rand(255).chr }.join

  secret = 'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK'
  target_bytes = secret.unpack("m0").first

  plain_text = random_prefix + attacker_controlled + target_bytes

  padded = CBCEncryptor.pad(plain_text, KEYSIZE)

  ecb = ECBEncryptor.new(@key)
  ecb.encrypt(padded)
end

# Goal: decrypt target-bytes

# How?
# We can generate two identical blocks that we know it will be duplicated
# in sequential blocks of ct if the blocks are block-aligned.
# We can't control block-alignment since we don't know the prefix length.
# We could determine the prefix len, if it is fixed, by prepending to
# our double-block.  If it's not fixed we have to make many requests and
# filter out the ones that are block-aligned (have repeating sequential ct).
#
# Ex: suppose block size is 4
# Key: random-prefix chars='R'
#      target chars (unknown or known)='A..Z'
#      our pt chars='a..z'
#
# Byte-aligned:
# RRRR abcd abcd ABCD EFGH IJKL
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123

# Byte-misaligned:
# RRRR RRab cdab cdAB CDEF GHIJ KLMN
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123
#
# To shift in the first char of target-bytes (assuming byte alignment),
# try all chars in the last byte of block 0 & remove last char of block 1:
# RRRR abc? abcA BCDE FGHI JKLM
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123
#
# But now we don't know if we are byte aligned when looping through ? values.
# Solution: a third duplicate block to indicate block-alignment:
# (Let's assume, for simplicity's sake that the random prefix can be greater
# than the block size.  Otherwise we'd need to try more padding in front of
# out pt so that we will get duplicate ct.)
#
# RRRR abc? abc? abcA BCDE FGHI JKLM
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123
#
# Next byte is much the same:
# RRRR abA? abA? abAB CDEF GHIJ KLM
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123
#
# After reading "ABCD", shift "A" out and compare vs the next unknown byte.
# We also need to append the correct # of padding chars to align target-bytes:
# RRRR BCD? BCD? aaaA BCDE FGHI JKLM
# 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123 0123
#
# Naming:
#   block #'s are counted w/r/t our provided text
#
# This different from the alg in Challenge 12 in two ways:
#   1) we need to detect and only work with block-aligned results
#   2) we need to identify the ct block matching where our pt starts

# Requests an encryption of pt
# Asks oracle multiple times until duplicate sequential ct blocks are sequential
# Only then does it return
# Returns: (ct, pt_start_block)
# Input: pt must be even multiple of blocksize to ensure duplicate ct block seen

def repeating_block(t)
  block = -1
  (0..t.length/BLOCKSIZE).each do |block_num|
    if t[block_num*BLOCKSIZE..block_num*BLOCKSIZE+BLOCKSIZE-1] ==
       t[(block_num+1)*BLOCKSIZE..(block_num+1)*BLOCKSIZE+BLOCKSIZE-1]
      puts block_num
      block = block_num
    end
  end
  block
rescue
  puts "WARNING: No repeating block found."
  block
end

def ask(pt)
  trial = nil
  loop do
    trial = encryption_oracle(pt)
    break if repeats(trial, BLOCKSIZE)
  end
  block = repeating_block(trial)
  [trial, block]
end

puts ask('YELLOW SUBMARINE'*2)

def decrypt(prefix_count, so_far, block_num)
  r = 'a'*prefix_count
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

def decrypt_block
  pt_so_far = ''
  (0..1000).each do |byte|
    block_num = byte / 16 # Block including char we are identifying
    if byte < 16
      pos_to_insert = 16-byte
      prefix_count = (pos_to_insert-1)
      decrypted_char = decrypt(prefix_count, pt_so_far, block_num)
      pt_so_far += decrypted_char.chr
    else
      pt_so_far = pt_so_far[1..15]
      decrypted_char = decrypt(15-byte%16, pt_so_far, block_num)
      break unless decrypted_char
      pt_so_far += decrypted_char.chr
    end
    print(decrypted_char.chr)
  end
end

# decrypt_block
