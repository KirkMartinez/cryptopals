# Challenge 8: identify AES-128 in ECB mode
#
# Assume plaintext has bytes repeated in 16 byte blocks of plaintext
# Duplicate ciphertext bytes are evidence for ECB mode

# Input: hex-encoded string
# Output: true if bytes raw bytes repeat somewhere in the string
def repeats(s_hex, bytes=16)
  #puts "Find #{bytes} byte repeats in #{s_hex}"
  hex_digits = bytes * 2
  raw = s_hex
  (0..raw.length-(2*hex_digits-1)).step(2).each do |offset|
    (offset+hex_digits..raw.length-(2*hex_digits-1)).step(2).each do |offset2|
      #puts "Compare #{offset}..#{offset+hex_digits-1} vs #{offset2}..#{offset2+hex_digits-1}"
      #puts "#{raw[offset..offset+hex_digits-1]} vs #{raw[offset+hex_digits..offset+(2*hex_digits-1)]}"
      if raw[offset..offset+hex_digits-1] == raw[offset2..offset2+hex_digits-1]
        puts "#{bytes} bytes match starting at offset #{offset}: #{raw[offset..offset+hex_digits-1]}"
        return true
      end
    end
  end
  return false
end

# x=(0..190).map {|x| x.chr}.join.unpack('H*').first
# puts x
# repeats(x+x)
# exit(1)

rep = 16
while rep > 1 do
  puts "Look for #{rep} repeating characters..."
  hex_lines = File.open('../data/8.txt', 'rb').each_line
  hex_lines.each_with_index do |line, i|
    if repeats(line, rep)
      puts "L#{i} shows #{rep} repeated characters:\n #{line}"
      #decrypt_it(line)
      exit(0)
    end
  end
  rep -= 1
end
