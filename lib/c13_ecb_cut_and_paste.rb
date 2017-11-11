# Challenge 13
require_relative 'cbc_encryptor'
require_relative 'ecb_encryptor'
require_relative 'utilities'

KEYSIZE=16

def encode(profile)
  profile.map {|k,v| "#{k}=#{v}" }.join('&')
end

@db = []
def parse(s)
  profile = {}
  s.split('&').each do |part|
    (k, v) = part.split('=')
     profile[k] = v
  end
  @db.push(profile)
  return encode(profile)
end

def profile_for(email)
  email = email.gsub(/[&=]/,'')
  uid = @db.length
  p = "email=#{email}&uid=#{uid}&role=user"
  parse(p)
end

@key = (1..16).map {rand(256).chr}.join
def encrypt(profile)
  padded = CBCEncryptor.pad(profile, KEYSIZE)
  ecb = ECBEncryptor.new(@key)
  ecb.encrypt(padded)
end

def decrypt(ct)
  ecb = ECBEncryptor.new(@key)
  ecb.decrypt(ct)
end

p = profile_for("ki&rkm@sq=uare")
e = encrypt(p)
# puts parse(decrypt(e))
#
# puts "DB: #{@db}"

def oracle(email)
  p = profile_for(email)
  encrypt(p)
end

# Using only the user input to profile_for() (as an oracle to generate "valid" ciphertexts)
# and the ciphertexts themselves, make a role=admin profile.

# call encrypt() on arbitrary values from profile_for()
# process the results however
# generate a ciphertext that has role=admin

# We can (assuming single-digit uid)
# email=xxxxxxxxxx xxxx&uid=0&role= user
# 0123456789abcdef 0123456789abcdef 0123456789abcdef
email = 'a'*14
step1 = oracle(email)
puts "step1: #{step1.unpack('H*')} (#{step1.length})"
# And then replace the last byte above with just "admin" PKCS#7-padded (\)
# email=xxxxxxxxxx admin\\\\\\\\\\\ &uid=0&role=user \\\\\\\\\\\\\\\\
# 0123456789abcdef 0123456789abcdef 0123456789abcdef 0123456789abcdef
email = 'a'*10 + 'admin' + 11.chr*11
raise unless CBCEncryptor.pad('admin', 16) == 'admin'+11.chr*11
step2 = oracle(email)
puts "step2: #{step2.unpack('H*')} (#{step2.length})"

admin = step1
admin[2*16..2*16+15] = step2[1*16..1*16+15]
puts "admin  #{admin.unpack('H*')} (#{admin.length})"
confirmation = decrypt(admin)
puts "Confirmation: #{confirmation} (#{confirmation.length})"
puts confirmation.unpack('H*')

puts "Enc raw:      #{encrypt('email=aaaaaaaaaaaaaa&uid=1&role=admin').unpack('H*')}"
puts "Dec raw:      #{decrypt(encrypt('email=aaaaaaaaaaaaaa&uid=1&role=admin'))}"
# Almost...the admin padding is being decrypted...
# Known issue: see skipped spec in cbc_encryptor_spec
#  Since we pad pre-ECB-encrypt, we also need to un-pad-post-ECB-decrypt
