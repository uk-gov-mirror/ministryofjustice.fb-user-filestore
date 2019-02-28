require 'aws-sdk-s3'
require 'tempfile'

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
        @temp_file ||= Tempfile.new('foo')
      end

      def bucket_name
        'moj-formbuilder'
      end

      def client
        @client ||= Aws::S3::Client.new
      end
    end
  end
end
