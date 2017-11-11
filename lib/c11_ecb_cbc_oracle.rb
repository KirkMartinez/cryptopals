# Challenge 11: EBC/CBC encryption oracle
#
# An oracle is a system which leaks some information.
# They are not desireable, but may unintentionally allow
# someone to break your encryption.
require_relative 'ecb_encryptor'
require_relative 'cbc_encryptor'
require_relative 'utilities'

KEYSIZE=16

# We create an oracle which encrypts the given data
# using a purely random key, and either ECB or CBC.
def encryption_oracle(data)
  # prepend and append some random chars to the data
  # (why are we doing this?)
  pre = rand(6)+5
  post = rand(6)+5
  plain_text = data
  plain_text.prepend( (1..pre).map {rand(256).chr}.join )
  plain_text.concat( (1..post).map {rand(256).chr}.join )
  plain_text = CBCEncryptor.pad(plain_text, KEYSIZE)

  key = (1..16).map {rand(256).chr}.join

  if rand(2) > 0
    puts "[Oracle using ECB]"
    ecb = ECBEncryptor.new(key)
    ecb.encrypt(plain_text)
  else
    puts "[Oracle using CBC]"
    iv = (1..16).map {rand(256).chr}.join
    cbc = CBCEncryptor.new(key)
    cbc.encrypt(plain_text, iv)
  end
end

# Now we can try to leverage the oracle to determine which mode is being used
# Since we know ECB will give duplicate ciphertext given identical blocks
# of plaintext, we can simply provide a large, repeating input and look for
# repeated blocks in the output (which will also tell us key length):


r = 'a'*64
(1..10).each do |try|
  enc = encryption_oracle(r)
  if repeats(enc)
    puts "Looks like ECB"
  else
    puts "CBC, bro"
  end
end
