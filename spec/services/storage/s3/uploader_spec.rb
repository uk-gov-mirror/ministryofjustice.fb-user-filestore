require 'rails_helper'

RSpec.describe Storage::S3::Uploader do
  let(:test_client) { Aws::S3::Client.new(stub_responses: stub_responses) }

  before :each do
    allow(Aws::S3::Client).to receive(:new).and_return(test_client)
  end

  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/upload-fingerprint' }

  subject do
    described_class.new(path: path, key: key)
  end

  describe '#upload' do
    describe do
      let(:stub_responses) do
        {
          head_object: [ false, { content_length: 150 } ],
          put_object: [{}],
        }
      end

      it 'uploads file to s3' do
        expect(subject.exists?).to be_falsey
        subject.upload
        expect(subject.exists?).to be_truthy
      end
    end

    after :each do
      subject.purge_from_s3!
    end
  end

  describe '#created_at' do
    let(:now) { Time.now.utc }

    let(:stub_responses) do
      {
        head_object: [
          { content_length: 150, last_modified: now },
        ],
        put_object: [{}],
      }
    end

    it 'returns creation timestamp' do
      subject.upload
      expect(subject.created_at).to be_within(10.seconds).of(now)
    end
  end
end
