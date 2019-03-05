require 'securerandom'

class FileManager
  attr_reader :file

  def initialize(encoded_file, options = {})
    @encoded_file = encoded_file
    @max_size = options[:max_size] ? options[:max_size].to_i : nil
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

  private

  attr_accessor :encoded_file, :max_size
end
