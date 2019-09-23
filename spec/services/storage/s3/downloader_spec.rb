require 'rails_helper'

RSpec.describe Storage::S3::Downloader do
  let(:upload_client) { Aws::S3::Client.new(stub_responses: upload_responses) }
  let(:download_client) { Aws::S3::Client.new(stub_responses: download_responses) }
  let(:download_responses) { {} }
  let(:upload_responses) { {} }
  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/download-fingerprint' }
  let(:bucket) { ENV['AWS_S3_BUCKET_NAME'] }
  let(:subject) { described_class.new(key: key, bucket: bucket) }

  before :each do
    allow(subject).to receive(:client).and_return(download_client)
  end

  describe '#contents' do
    describe do
      let(:download_responses) do
        {
          head_object: [{ content_length: 150 }],
          get_object: [{ body: "ce030d6aac29d4a5a8b03f7428ff4626" }],
          delete_object: {}
        }
      end

      it 'contains correct contents' do
        expect(subject.contents).to eql("lorem ipsum\n")
      end
    end
  end
end
