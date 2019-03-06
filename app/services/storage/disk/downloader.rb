require 'tempfile'
require 'securerandom'

module Storage
  module Disk
    class Downloader
      def initialize(key:)
        @key = key
      end

      def download
        FileUtils.cp(path, temp_file.path)
      end

      def exists?
        File.exist?(path)
      end

      def purge_from_source!
      end

      def purge_from_destination!
      end

      private

      attr_accessor :key

      def path
        Rails.root.join('tmp/files', key)
      end

      def temp_file
        @temp_file ||= Tempfile.new(filename)
      end

      def filename
        @filename ||= SecureRandom.hex
      end
    end
  end
end
