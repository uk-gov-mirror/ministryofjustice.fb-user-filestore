require 'pathname'
require 'fileutils'

module Storage
  module Disk
    class Uploader
      def initialize(path:, key:)
        @path = Pathname.new(path)
        @key = key
      end

      def upload
        FileUtils.mkdir_p(destination_folder)
        FileUtils.cp(path, destination_path)
      end

      def exists?
        FileUtils.mkdir_p(destination_folder)
        File.exist?(destination_path)
      end

      def self.purge_destination!
        FileUtils.rm_r(Rails.root.join('tmp/files/'))
      end

      private

      attr_accessor :path, :key

      def destination_folder
        destination_path.to_s.split('/')[0..-2].join('/')
      end

      def destination_path
        Rails.root.join('tmp/files/', key)
      end

      def file
        File.open(path)
      end
    end
  end
end
