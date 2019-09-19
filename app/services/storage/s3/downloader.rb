require 'aws-sdk-s3'
require 'tempfile'

module Storage
  module S3
    class Downloader
      def initialize(key:)
        @key = key
      end

      def exists?
        begin
          client.head_object(bucket: bucket, key: key)
          true
        rescue Aws::S3::Errors::NotFound
          false
        end
      end

      def purge_from_source!
        client.delete_object(bucket: bucket, key: key)
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
        client.get_object(
          response_target: temp_file.path,
          bucket: bucket,
          key: key
        )
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

      def temp_file
        @temp_file ||= Tempfile.new
      end

      def bucket
        ENV['AWS_S3_BUCKET_NAME']
      end

      def client
        @client ||= Aws::S3::Client.new
      end
    end
  end
end
