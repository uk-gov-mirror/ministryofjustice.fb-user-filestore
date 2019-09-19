require 'securerandom'
require 'digest'

class FileManager
  attr_reader :file

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

  def has_virus?
    MalwareScanner.call(path_to_file)
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
    Rails.configuration.x.storage_adapter.constantize::Uploader.new(path: path_to_file, key: key, bucket: bucket)
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

  def bucket
    ENV['AWS_S3_BUCKET_NAME']
  end
end
