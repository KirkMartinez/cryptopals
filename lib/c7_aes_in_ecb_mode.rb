# Challenge 7: decrypt given with AES-128 in ECB mode
# See: http://ruby-doc.org/stdlib-2.3.1/libdoc/openssl/rdoc/OpenSSL/Cipher.html
$LOAD_PATH.unshift(File.expand_path('.'))

require 'openssl'

cipher = OpenSSL::Cipher.new('AES-128-ECB')
cipher.decrypt
cipher.key = 'YELLOW SUBMARINE'

ciphertext_64 = File.open('../data/7.txt', 'rb').read().gsub(/\r/,'').gsub(/\n/,'')
ciphertext_raw = ciphertext_64.unpack("m0").first

plain = cipher.update(ciphertext_raw) + cipher.final

puts plain
