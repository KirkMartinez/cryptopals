class FileReader
  # input: file path
  # output: three encodings of the file contents [64, raw, hex]
  def self.load(file)
    c_64 = File.open("../data/#{file}", 'rb').read().gsub(/\r/,'').gsub(/\n/,'')
    c_raw = c_64.unpack("m0").first
    c_hex = c_raw.unpack('H*').first
    return [c_64, c_raw, c_hex]
  end
end
