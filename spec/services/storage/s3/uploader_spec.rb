require 'rails_helper'

RSpec.describe Storage::S3::Uploader do
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:key) { '28d/service-slug/upload-fingerprint' }
  let(:bucket) { ENV['AWS_S3_BUCKET_NAME'] }
  let(:downloader) { Storage::S3::Downloader.new(key: key, bucket: bucket) }
  let(:subject) { described_class.new(key: key, bucket: bucket) }

  before :each do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  describe '#exists?' do
    context 'when a file does not exist in s3' do
      before do
        s3.stub_responses(:head_object, 'NotFound')
      end

      it 'returns false' do
        expect(subject.exists?).to eq(false)
      end
    end

    context 'when a file exists in s3' do
      before do
        s3.stub_responses(:head_object, {})
      end

      it 'returns true' do
        expect(subject.exists?).to eq(true)
      end
    end
  end


  describe '#upload' do
    let(:file_data) do
      File.read(file_fixture('lorem_ipsum.txt'))
    end

    before do
      s3.stub_responses(:put_object, {})
    end

    it 'uploads file to s3' do
      expect(s3).to receive(:put_object).with(bucket: bucket, key: key, body: file_data)
      subject.upload(file_data: file_data)
    end
  end

  describe '#created_at' do
    let(:now) { Time.now.utc }

    before do
      s3.stub_responses(
        :head_object,
        Aws::S3::Types::HeadObjectOutput.new(last_modified: now)
      )
    end

    it 'returns creation timestamp' do
      expect(subject.created_at).to eq(now)
    end
  end
end
