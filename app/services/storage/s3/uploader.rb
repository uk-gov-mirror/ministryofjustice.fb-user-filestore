require 'aws-sdk-s3'
require 'pathname'

module Storage
  module S3
    class Uploader
      def initialize(path:, key:)
        @path = Pathname.new(path)
        @key = key
      end

      def upload
        object.upload_file(path)
      end

      def exists?
        object.exists?
      end

      def purge_from_s3!
        object.delete
      end

      def created_at
        object.last_modified
      end

      private

      attr_accessor :path, :key

      def object
        @object ||= Aws::S3::Object.new(bucket_name, key, client: client)
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
