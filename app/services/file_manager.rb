require 'securerandom'

class FileManager
  attr_reader :file

  def initialize(encoded_file)
    @encoded_file = encoded_file
  end

  def save_to_disk
    @file = File.open(Rails.root.join('tmp/files/quarantine/', random_filename), 'wb')
    @file.write(Base64.decode64(encoded_file))
    @file.close
  end

  def random_filename
    @random_filename ||= SecureRandom.hex
  end

  private

  attr_accessor :encoded_file
end
