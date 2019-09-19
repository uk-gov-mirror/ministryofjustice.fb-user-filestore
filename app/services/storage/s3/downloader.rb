require 'aws-sdk-s3'
require 'tempfile'

module Storage
  module S3
    class Downloader
      def initialize(key:, bucket:)
        @bucket = bucket
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

      attr_accessor :key, :bucket

      def download
        object.download_file(temp_file.path)
        decrypt(temp_file.path)
      end

      def decrypt(file)
        file = File.open(file, 'rb')
        data = file.read
        result = Cryptography.new(file: data).decrypt
        file = File.open(file, 'wb')
        file.write(result)
        file.close
      end

      def object
        @object ||= Aws::S3::Object.new(bucket, key, client: client)
      end

      def temp_file
        @temp_file ||= Tempfile.new
      end

      def client
        @client ||= Aws::S3::Client.new
      end
    end
  end
end
