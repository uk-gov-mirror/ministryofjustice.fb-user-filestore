require 'rails_helper'

RSpec.describe Storage::Disk::Downloader do
  let(:uploader) { Storage::Disk::Uploader.new(path: path, key: key) }
  subject { described_class.new(key: key) }

  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/download-fingerprint' }

  around :each do |example|
    reset_test_directories!
    example.run
  end

  describe '#exists?' do
    context 'when the file doesnt exist' do
      it 'returns false' do
        expect(subject.exists?).to be_falsey
      end
    end

    context 'when the file exists' do
      before :each do
        FileUtils.touch(Rails.root.join('tmp/files/', key))
      end

      it 'returns truthy' do
        expect(subject.exists?).to be_truthy
      end
    end
  end

  describe '#contents' do
    before :each do
      uploader.upload
    end

    describe do
      it 'contains correct contents' do
        expect(subject.contents).to eql("lorem ipsum\n")
      end
    end

    after :each do
      subject.purge_from_source!
      subject.purge_from_destination!
    end
  end
end
