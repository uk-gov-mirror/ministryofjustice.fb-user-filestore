require 'aws-sdk-s3'
require 'tempfile'
require 'securerandom'

module Storage
  module S3
    class Downloader
      def initialize(key:)
        @key = key
      end

      def download
        object.download_file(temp_file.path)
      end

      def exists?
        object.exists?
      end

      def purge_from_s3!
        object.delete
      end

      def purge_from_disk!
        temp_file.unlink
      end

      private

      attr_accessor :key

      def object
        @object ||= Aws::S3::Object.new(bucket_name, key, client: client)
      end

      def temp_file
        @temp_file ||= Tempfile.new(filename_with_extension)
      end

      def filename_with_extension
        @filename_with_extension ||= object.metadata.fetch('filename_with_extension', SecureRandom.hex)
      end

      def bucket_name
        ENV['AWS_S3_BUCKET_NAME']
      end

      def client
        @client ||= Aws::S3::Client.new
      end
    end
  end
end
