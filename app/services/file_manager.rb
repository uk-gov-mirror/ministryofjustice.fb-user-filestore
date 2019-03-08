require 'securerandom'
require 'digest'

class FileManager
  attr_reader :file, :encrypted_file

  def initialize(encoded_file:, user_id:, service_slug:,
                 encrypted_user_id_and_token:, options: {})
    @encoded_file = encoded_file
    @user_id = user_id
    @service_slug = service_slug
    @encrypted_user_id_and_token = encrypted_user_id_and_token
    @max_size = options[:max_size] ? options[:max_size].to_i : nil
    @allowed_types = options.fetch(:allowed_types, [])
    @days_to_live = options.fetch(:days_to_live, 28).to_i
  end

  def save_to_disk
    ensure_quarantine_folder_exists
    @file = File.open(path_to_file, 'wb')
    @file.write(Base64.strict_decode64(encoded_file))
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
    MimeChecker.new(mime_type, allowed_types).call
  end

  def mime_type
    @mime_type ||= `file --b --mime-type '#{path_to_file}'`.strip
  end

  def encrypt
    file = File.open(path_to_file)
    data = file.read
    file.close
    result = Cryptography.new(file: data).encrypt
    save_encrypted_to_disk(result)
  end

  def save_encrypted_to_disk(data)
    ensure_encrypted_folder_exists
    @encrypted_file = File.open(path_to_encrypted_file, 'wb')
    @encrypted_file.write(data)
    @encrypted_file.close
  end

  def path_to_encrypted_file
    @path_to_encrypted_file ||= Rails.root.join('tmp/files/encrypted_data/', random_filename)
  end

  def ensure_encrypted_folder_exists
    FileUtils.mkdir_p(encrypted_folder)
  end

  def encrypted_folder
    Rails.root.join('tmp/files/encrypted_data/')
  end

  def upload
    uploader.upload
  end

  def file_fingerprint
    @file_fingerprint ||= Digest::SHA256.file(file).to_s
  end

  def fingerprint_with_prefix
    "#{days_to_live}d-#{file_fingerprint}"
  end

  def file_already_exists?
    uploader.exists?
  end

  def delete_file
    FileUtils.rm_f(path_to_file)
  end

  def expires_at
    uploader.created_at + days_to_live.days
  end

  private

  attr_accessor :encoded_file, :user_id, :service_slug, :max_size,
                :allowed_types, :days_to_live, :encrypted_user_id_and_token

  def uploader
    Rails.configuration.x.storage_adapter.constantize::Uploader.new(path: path_to_file, key: key)
  end

  def key
    KeyForFile.new(service_slug: service_slug,
                   user_id: user_id,
                   file_fingerprint: file_fingerprint,
                   days_to_live: days_to_live,
                   cipher_key: Digest::MD5.hexdigest(encrypted_user_id_and_token)).call
  end

  def ensure_quarantine_folder_exists
    FileUtils.mkdir_p(quarantine_folder)
  end

  def quarantine_folder
    Rails.root.join('tmp/files/quarantine/')
  end
end
