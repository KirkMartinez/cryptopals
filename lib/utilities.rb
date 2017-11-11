# Input: some data, and the size of the repeat to detect
# Output: if there is a copy of that many contiguous repeating bytes in the data
def repeats(raw, bytes=16)
  (0..raw.length-bytes-1).each do |offset|
    (offset+bytes..raw.length-bytes).each do |offset2|
      if raw[offset..offset+bytes-1] == raw[offset2..offset2+bytes-1]
        puts "Repeats starting at byte #{offset}"
        return true
      end
    end
  end
  return false
end
