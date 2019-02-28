require 'rails_helper'

RSpec.describe Storage::S3::Downloader do
  let(:test_client) { Aws::S3::Client.new(stub_responses: true) }

  before :each do
    # allow(Aws::S3::Client).to receive(:new).and_return(test_client)
  end

  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/download-fingerprint' }

  subject { described_class.new(key: key) }

  describe '#download' do
    let(:uploader) { Storage::S3::Uploader.new(path: path, key: key) }

    before :each do
      uploader.upload

      test_client.stub_responses(:get_object, [
        { body: "lorem ipsum\n" }
      ])
    end

    it 'downloads file from s3' do
      subject.download

      downloaded_path = subject.send(:temp_file).path

      contents = File.open(downloaded_path).read

      expect(contents).to eql("lorem ipsum\n")
    end

    after :each do
      subject.purge_from_s3!
      subject.purge_from_disk!
    end
  end
end
