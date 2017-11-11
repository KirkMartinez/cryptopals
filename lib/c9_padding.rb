# Challenge 9
require_relative 'cbc_encryptor'

# It's the plaintext that needs padding, not the key

raise "Wrong." unless CBCEncryptor.pad('YELLOW SUBMARINE', 20) === "YELLOW SUBMARINE\x04\x04\x04\x04"
raise "Wrong." unless CBCEncryptor.pad('YELLOW SUBMARINE', 16) === "YELLOW SUBMARINE"+"\x10"*16
raise "Wrong." unless CBCEncryptor.pad('YELLOW SUBMARINE', 5) === "YELLOW SUBMARINE\x04\x04\x04\x04"
