require 'securerandom'

class FileManager
  attr_reader :file

  def initialize(encoded_file, options = {})
    @encoded_file = encoded_file
    @max_size = options[:max_size] ? options[:max_size].to_i : nil
    @allowed_types = options.fetch(:allowed_types, [])
  end

  def save_to_disk
    @file = File.open(Rails.root.join('tmp/files/quarantine/', random_filename), 'wb')
    @file.write(Base64.decode64(encoded_file))
    @file.close
  end

  def random_filename
    @random_filename ||= SecureRandom.hex
  end

  def file_too_large?
    file_size > max_size if max_size
  end

  def file_size
    @file_size = File.size("tmp/files/quarantine/#{random_filename}")
  end

  def type_permitted?
    allowed_types.include?(mime_type)
  end

  def mime_type
    @mime_type ||= `file --b --mime-type 'tmp/files/quarantine/#{random_filename}'`.strip
  end

  private

  attr_accessor :encoded_file, :max_size, :allowed_types
end
