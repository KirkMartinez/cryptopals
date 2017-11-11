# Challenge 2
#
# You can pack an array (elments int, float, string representing raw input data) into a string.
#   http://www.rubydoc.info/stdlib/core/Array:pack
# You can unpack a string into an array of values based on the formatting character (how to interpret string).
#   http://www.rubydoc.info/stdlib/core/String#unpack-instance_method

i='1c0111001f010100061a024b53535009181c'
x='686974207468652062756c6c277320657965'
o='746865206b696420646f6e277420706c6179'

input = [i].pack('H*')
xor_with = [x].pack('H*')

puts "Input #{input.class}: #{input}"
puts "Xor   #{xor_with.class}: #{xor_with}"

in_int = input.unpack('H*').first.to_i(16)
puts "int_int: #{in_int}"
xor_int = xor_with.unpack('H*').first.to_i(16)
puts "xor_int: #{xor_int}"

xored_int = in_int ^ xor_int
puts "xored_int: #{xored_int}"

xored = xored_int.to_s(16)
puts "Xored: #{xored}"

raise "Does not match" unless xored == o


