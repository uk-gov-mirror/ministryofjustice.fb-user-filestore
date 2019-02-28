require 'rails_helper'

RSpec.describe Storage::S3::Uploader do
  let(:test_client) { Aws::S3::Client.new(stub_responses: true) }

  before :each do
    allow(Aws::S3::Client).to receive(:new).and_return(test_client)
  end

  let(:path) do
    file_fixture('lorem_ipsum.txt')
  end

  subject do
    described_class.new(path: path)
  end

  describe '#upload' do
    before :each do
      test_client.stub_responses(:head_object, [
        false,
        { content_length: 150 }
      ])
    end

    it 'uploads file to s3' do
      expect(subject.exists?).to be_falsey
      subject.upload
      expect(subject.exists?).to be_truthy
    end

    after :each do
      subject.purge_from_s3!
    end
  end
end
