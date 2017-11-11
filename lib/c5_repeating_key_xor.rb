# Challenge 5
#
$LOAD_PATH.unshift(File.expand_path('.'))

require 'xor_encryptor'

plain_text = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"

key = 'ICE'

expected_cypher_text = '0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f'


encryptor = XorEncryptor.new(key)
hex_plain_text = plain_text.unpack('C*').map {|c| XorEncryptor.two_digit_hex(c)}.join

puts "LINE: --#{plain_text}--"
puts "HEX : #{hex_plain_text}"
puts "ENC : #{encryptor.encode(hex_plain_text)}"
puts "EXP : #{expected_cypher_text}"

raise "Not a match" unless encryptor.encode(hex_plain_text) == expected_cypher_text
