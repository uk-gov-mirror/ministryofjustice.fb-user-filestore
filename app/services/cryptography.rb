class Cryptography

  IV = '1234567890123451'.freeze
  KEY = 'a9c12000de36def805e4c2107bd8e910'.freeze

  def initialize(file:)
    @file = file
  end

  def encrypt
    cipher.encrypt
    cipher.iv = IV
    cipher.key = KEY
    encrypted_data = cipher.update(@file) + cipher.final
    encrypted_data.unpack1('H*')
  end

  def decrypt
    cipher.decrypt
    cipher.iv = IV
    cipher.key = KEY
    data = [@file].pack('H*').unpack('C*').pack('c*')
    cipher.update(data) + cipher.final
  end

  def cipher
    @cipher ||= OpenSSL::Cipher.new 'AES-256-CBC'
  end
end
