require 'rails_helper'

RSpec.describe Storage::S3::Uploader do
  let(:key) { '28d/service-slug/upload-fingerprint' }

  context 'when calling public methods' do
    let(:subject) { described_class.new(key: key, bucket: bucket) }
    let(:bucket) { ENV['AWS_S3_BUCKET_NAME'] }
    let(:downloader) { Storage::S3::Downloader.new(key: key, bucket: bucket) }
    let(:s3) { Aws::S3::Client.new(stub_responses: true) }

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

  context 'when different S3 credentials are required' do
    let(:bucket) { ENV['AWS_S3_EXTERNAL_BUCKET_NAME'] }

    context 'with default credentials' do
      let(:subject) { described_class.new(key: key, bucket: bucket) }
      let(:expected_config) do
        {
          access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
          stub_responses: true
        }
      end

      it 'should create the S3 client with the default credentials' do
        expect(Aws::S3::Client).to receive(:new).with(expected_config).and_call_original
        subject.upload(file_data: "abc")
      end
    end

    context 'with alternative credentials' do
      let(:subject) do
        described_class.new(key: key, bucket: bucket, s3_config: external_config)
      end
      let(:external_config) { Rails.configuration.x.s3_external_bucket_config }

      it 'should create the S3 client with the injected credentials' do
        expect(Aws::S3::Client).to receive(:new).with(external_config).and_call_original
        subject.upload(file_data: "abc")
      end
    end
  end
end
