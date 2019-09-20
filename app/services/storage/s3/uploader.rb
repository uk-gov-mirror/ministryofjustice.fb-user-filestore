require 'aws-sdk-s3'
require 'pathname'

module Storage
  module S3
    class Uploader
      def initialize(path:, key:, bucket:)
        @path = Pathname.new(path)
        @key = key
        @bucket = bucket
      end

      def upload
        encrypt
        File.open(path_to_encrypted_file, 'rb') do |file|
          client.put_object(bucket: bucket, key: key, body: file)
        end
        File.delete(path_to_encrypted_file)
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
        meta_data = client.head_object({bucket: bucket, key: key})
        meta_data.last_modified
      end

      private

      attr_accessor :path, :key, :bucket

      def encrypt
        file = File.open(path, 'rb')
        data = file.read
        file.close
        result = Cryptography.new(file: data).encrypt
        save_encrypted_to_disk(result)
      end

      def save_encrypted_to_disk(data)
        ensure_encrypted_folder_exists
        encrypted_file = File.open(path_to_encrypted_file, 'wb')
        encrypted_file.write(data)
        encrypted_file.close
      end

      def path_to_encrypted_file
        @path_to_encrypted_file ||= Rails.root.join('tmp/files/encrypted_data/', random_filename)
      end

      def ensure_encrypted_folder_exists
        FileUtils.mkdir_p(encrypted_folder)
      end

      def encrypted_folder
        Rails.root.join('tmp/files/encrypted_data/')
      end

      def client
        @client ||= Aws::S3::Client.new
      end

      def random_filename
        @random_filename ||= SecureRandom.hex
      end
    end
  end
end
