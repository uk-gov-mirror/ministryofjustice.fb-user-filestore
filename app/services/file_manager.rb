require 'securerandom'
require 'digest'

class FileManager
  attr_reader :file

  def initialize(encoded_file:, user_id:, service_slug:, options: {})
    @encoded_file = encoded_file
    @user_id = user_id
    @service_slug = service_slug
    @max_size = options[:max_size] ? options[:max_size].to_i : nil
    @allowed_types = options.fetch(:allowed_types, [])
  end

  def save_to_disk
    ensure_quarantine_folder_exists
    @file = File.open(path_to_file, 'wb')
    @file.write(Base64.decode64(encoded_file))
    @file.close
  end

  def path_to_file
    @path_to_file ||= Rails.root.join('tmp/files/quarantine/', random_filename)
  end

  def random_filename
    @random_filename ||= SecureRandom.hex
  end

  def file_too_large?
    file_size > max_size if max_size
  end

  def file_size
    @file_size ||= File.size(path_to_file)
  end

  def type_permitted?
    allowed_types.include?(mime_type)
  end

  def mime_type
    @mime_type ||= `file --b --mime-type '#{path_to_file}'`.strip
  end

  def upload
    uploader.upload
  end

  def file_fingerprint
    @file_fingerprint ||= Digest::SHA256.file(file).to_s
  end

  def file_already_exists?
    uploader.exists?
  end

  private

  def uploader
    Storage::Disk::Uploader.new(path: path_to_file, key: key)
  end

  def service_token
    service_slug
  end

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

  def key
    "28d/#{hash_encrypted_digest}"
  end

  def ensure_quarantine_folder_exists
    FileUtils.mkdir_p(quarantine_folder)
  end

  def quarantine_folder
    Rails.root.join('tmp/files/quarantine/')
  end

  attr_accessor :encoded_file, :user_id, :service_slug, :max_size, :allowed_types
end
