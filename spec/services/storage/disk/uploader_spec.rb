require 'rails_helper'

RSpec.describe Storage::Disk::Uploader do
  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/upload-fingerprint' }

  subject do
    described_class.new(path: path, key: key)
  end

  around :each do |example|
    reset_test_directories!
    example.run
  end

  describe '#upload' do
    describe do
      it 'saves files to disk' do
        expect(subject.exists?).to be_falsey
        subject.upload
        expect(subject.exists?).to be_truthy
      end
    end
  end

  describe '#created_at' do
    it 'returns creation timestamp' do
      subject.upload
      expect(subject.created_at).to be_within(10.seconds).of(Time.now)
    end
  end
end
