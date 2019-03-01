require 'rails_helper'

RSpec.describe Storage::S3::Downloader do
  let(:upload_client) { Aws::S3::Client.new(stub_responses: upload_responses) }
  let(:download_client) { Aws::S3::Client.new(stub_responses: download_responses) }

  let(:download_responses) { {} }
  let(:upload_responses) { {} }

  let(:uploader) { Storage::S3::Uploader.new(path: path, key: key) }
  subject { described_class.new(key: key) }

  before :each do
    allow(uploader).to receive(:client).and_return(upload_client)
    allow(subject).to receive(:client).and_return(download_client)
  end

  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/download-fingerprint' }

  describe '#download' do
    before :each do
      uploader.upload
    end

    describe do
      let(:download_responses) do
        {
          head_object: [{ content_length: 150, metadata: { 'filename_with_extension' => 'lorem_ipsum.txt' }}],
          get_object: [{ body: "lorem ipsum\n" }]
        }
      end

      it 'downloads file from s3' do
        subject.download

        downloaded_path = subject.send(:temp_file).path

        expect(downloaded_path).to include('lorem_ipsum.txt')

        contents = File.open(downloaded_path).read

        expect(contents).to eql("lorem ipsum\n")
      end
    end

    context 'when missing metadata' do
      let(:stub_responses) do
        {
          put_object: [{}],
          get_object: [{ body: "lorem ipsum\n" }],
        }
      end

      it 'uses random hex string for filename' do
        allow(subject.send(:object)).to receive(:metadata).and_return({})

        subject.download

        downloaded_path = subject.send(:temp_file).path

        expect(downloaded_path).to match(/[a-f0-9]{32}/)
      end
    end

    after :each do
      subject.purge_from_s3!
      subject.purge_from_disk!
    end
  end
end
