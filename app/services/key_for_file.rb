class KeyForFile
  def initialize(service_slug:, user_id:, file_fingerprint:)
    @service_slug = service_slug
    @user_id = user_id
    @file_fingerprint = file_fingerprint
  end

  def call
    @call ||= "28d/#{hash_encrypted_digest}"
  end

  private

  attr_accessor :service_slug, :user_id, :file_fingerprint

  def digest
    @digest ||= Digest::SHA256.hexdigest(service_token + user_id + file_fingerprint)
  end

  def encrypted_digest
    return @encrypted_digest if @encrypted_digest

    cipher = OpenSSL::Cipher.new 'AES-256-CBC'
    cipher.encrypt
    cipher.iv = '1234567890123456'
    cipher.key = '12345678901234567890123456789012' # encrypted_user_id_and_token
    encrypted = cipher.update(digest) + cipher.final
    @encrypted_digest = encrypted.unpack1('H*')
  end

  def hash_encrypted_digest
    @hash_encrypted_digest ||= Digest::SHA256.hexdigest(encrypted_digest)
  end

  def service_token
    # service_token_client.call(service_slug)
    service_slug
  end
end
