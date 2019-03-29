require 'pathname'
require 'fileutils'

module Storage
  module Disk
    class Uploader
      def initialize(path:, key:)
        @path = Pathname.new(path)
        @key = key
      end

      def upload
        encrypt
        FileUtils.mkdir_p(destination_folder)
        FileUtils.cp(path_to_encrypted_file, destination_path)
      end

      def exists?
        FileUtils.mkdir_p(destination_folder)
        File.exist?(destination_path)
      end

      def self.purge_destination!
        FileUtils.rm_r(Rails.root.join('tmp/files/'))
      end

      def created_at
        File.ctime(destination_path)
      end

      private

      attr_accessor :path, :key

      def destination_folder
        destination_path.to_s.split('/')[0..-2].join('/')
      end

      def destination_path
        Rails.root.join('tmp/files/', key)
      end

      def file
        File.open(path)
      end

      def encrypt
        file = File.open(path)
        data = file.read
        file.close
        result = Cryptography.new(file: data).encrypt
        save_encrypted_to_disk(result)
      end

      def save_encrypted_to_disk(data)
        ensure_encrypted_folder_exists
        encrypted_file = File.open(path_to_encrypted_file, 'wb')
        encrypted_file.write(data)
        encrypted_file.close
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

      def random_filename
        @random_filename ||= SecureRandom.hex
      end
    end
  end
end
