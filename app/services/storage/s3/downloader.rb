require 'aws-sdk-s3'
require 'tempfile'

module Storage
  module S3
    class Downloader
      def initialize(path:)
        @path = path
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

      attr_accessor :path

      def object
        @object ||= Aws::S3::Object.new(bucket_name, 'filename', client: client)
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
