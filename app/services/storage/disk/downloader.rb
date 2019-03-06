require 'tempfile'
require 'securerandom'

module Storage
  module Disk
    class Downloader
      def initialize(key:)
        @key = key
      end

      def download
        FileUtils.cp(path, file.path)
      end

      def exists?
        File.exist?(path)
      end

      def purge_from_source!
      end

      def purge_from_destination!
      end

      def file
        @file ||= Tempfile.new(filename)
      end

      private

      attr_accessor :key

      def path
        Rails.root.join('tmp/files', key)
      end

      def filename
        @filename ||= SecureRandom.hex
      end
    end
  end
end
