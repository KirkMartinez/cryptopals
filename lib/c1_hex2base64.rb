# Challenge 1
#
# You can use [].pack to interpret the elements of the array based on the fmt, returning a string
# (of bytes) whose bits match the given array element(s).  Example:
#
# > ["0101"].pack('H*')                          interpret array as a string of hex digits
# => "\x01\x01"
# > ["0101"].pack('H*').unpack('B*')             show in binary for clarity
# => ["0000000100000001"]
# => ["000000", "010000", "0001"]                split into 6-bit units
# > [["0101"].pack('H*')].pack('m0')             base64
# => "AQE="
#
# Base64 encoding uses 6 bits per char.  In this case:
# A == 000000 (0)
# Q == 010000 (16)
# E == 000100 (4)
# = == null (padding)
#
# See: https://en.wikipedia.org/wiki/Base64#Base64_table
#
i = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
o = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'

def hex_to_base64(hex)
  [[hex].pack("H*")].pack("m0")
end

def base64_to_hex(base64)
  base64.unpack("m0").first.unpack("H*").first
end

raise "Does not match" unless hex_to_base64(i) === o

raise "Not inverses" unless i === base64_to_hex( hex_to_base64(i) )
