require 'aws-sdk-s3'
require 'tempfile'

module Storage
  module S3
    class Downloader
      def initialize(key:)
        @key = key
      end

      def exists?
        object.exists?
      end

      def purge_from_source!
        object.delete
      end

      def purge_from_destination!
        temp_file.unlink
      end

      def contents
        download
        temp_file.read
      end

      private

      attr_accessor :key

      def download
        object.download_file(temp_file.path)
      end

      def object
        @object ||= Aws::S3::Object.new(bucket_name, key, client: client)
      end

      def temp_file
        @temp_file ||= Tempfile.new
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
