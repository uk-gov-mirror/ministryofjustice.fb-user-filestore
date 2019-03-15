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

  describe '#encoded_contents' do
    before :each do
      uploader.upload
    end

    describe do
      let(:download_responses) do
        {
          head_object: [{ content_length: 150 }],
          get_object: [{ body: "lorem ipsum\n" }]
        }
      end

      it 'returns encoded file contents' do
        expect(subject.encoded_contents).to eql(Base64.strict_encode64("lorem ipsum\n"))
      end
    end

    after :each do
      subject.purge_from_source!
      subject.purge_from_destination!
    end
  end
end
