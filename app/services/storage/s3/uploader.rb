require 'aws-sdk-s3'
require 'pathname'

module Storage
  module S3
    class Uploader
      def initialize(key:, bucket:)
        @key = key
        @bucket = bucket
      end

      def upload(file_data:)
        client.put_object(bucket: bucket, key: key, body: file_data)
      end

      def exists?
        begin
          client.head_object(bucket: bucket, key: key)
          true
        rescue Aws::S3::Errors::NotFound
          false
        end
      end

      def purge_from_s3!
        client.delete_object(bucket: bucket, key: key)
      end

      def created_at
        meta_data = client.head_object(bucket: bucket, key: key)
        meta_data.last_modified
      end

      private

      attr_accessor :key, :bucket

      def client
        @client ||= Aws::S3::Client.new
      end
    end
  end
end
