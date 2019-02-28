require 'aws-sdk-s3'

module Storage
  module S3
    class Uploader
      def initialize(path:)
        @path = path
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

      attr_accessor :path

      def object
        @object ||= Aws::S3::Object.new(bucket_name, 'filename', client: client)
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
