# Challenge 4
#
require_relative 'xor_decoder'

class Words
    def initialize
        @words = words
    end

    # returns count of common words in given string
    def score(s)
        count = 0
        s.split.each do |word|
            count += 1 if @words.include?(word)
        end
        count
    end

    private

    def words
        File.open('words.txt').read.split
    end
end

words = Words.new
results = []
File.open('../data/4.txt').each do |line|
    (score, _key, decode) = XorDecoder.xor_decode(line)
    results.push [words.score(decode), decode]
end

results.sort! { |x,y| y[0] <=> x[0] }
puts results[0][1]
