require 'aws-sdk-s3'

module Storage
  module S3
    class Uploader
      def initialize(key:, bucket:, s3_config: default_s3_config)
        @key = key
        @bucket = bucket
        @s3_config = s3_config
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

      attr_accessor :key, :bucket, :s3_config

      def default_s3_config
        Rails.configuration.x.s3_internal_bucket_config
      end

      def client
        @client ||= Aws::S3::Client.new(s3_config)
      end
    end
  end
end
