require 'aws-sdk-s3'

module Storage
  module S3
    class Uploader
      def initialize(path:, key:)
        @path = path
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

      private

      attr_accessor :path, :key

      def object
        @object ||= Aws::S3::Object.new(bucket_name, key, client: client)
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
