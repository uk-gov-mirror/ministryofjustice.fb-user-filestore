require 'tempfile'
require 'securerandom'

module Storage
  module Disk
    class Downloader
      def initialize(key:)
        @key = key
      end

      def exists?
        File.exist?(path)
      end

      def purge_from_source!
      end

      def purge_from_destination!
        FileUtils.rm(file.path)
      end

      def file
        @file ||= Tempfile.new(filename)
      end

      def encoded_contents
        download
        Base64.strict_encode64(file.read)
      end

      private

      attr_accessor :key

      def path
        Rails.root.join('tmp/files', key)
      end

      def filename
        @filename ||= SecureRandom.hex
      end

      def decrypt(file)
        file = File.open(file)
        data = file.read
        result = Cryptography.new(file: data).decrypt
        file = File.open(file, 'wb')
        file.write(result)
        file.close
      end

      def download
        FileUtils.cp(path, file.path)
        decrypt(file.path)
      end
    end
  end
end
