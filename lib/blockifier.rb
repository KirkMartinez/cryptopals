class Blockifier
  def self.split(c_raw, block_size)
    return c_raw.chars.each_slice(block_size).to_a.map { |x| x.join }
  end
end
