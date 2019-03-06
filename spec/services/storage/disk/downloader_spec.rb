require 'rails_helper'

RSpec.describe Storage::Disk::Downloader do
  let(:uploader) { Storage::Disk::Uploader.new(path: path, key: key) }
  subject { described_class.new(key: key) }

  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/download-fingerprint' }

  describe '#download' do
    before :each do
      uploader.upload
    end

    describe do
      it 'downloads file from s3' do
        subject.download

        downloaded_path = subject.send(:file).path

        contents = File.open(downloaded_path).read

        expect(contents).to eql("lorem ipsum\n")
      end
    end

    after :each do
      subject.purge_from_source!
      subject.purge_from_destination!
    end
  end

  describe '#exists?' do
    before :each do
      FileUtils.rm_f(Rails.root.join('tmp/files/', key))
    end

    context 'when the file doesnt exist' do
      it 'returns false' do
        expect(subject.exists?).to be_falsey
      end
    end

    context 'when the file exists' do
      before :each do
        FileUtils.touch(Rails.root.join('tmp/files/', key))
      end

      after :each do
        FileUtils.rm_f(Rails.root.join('tmp/files/', key))
      end

      it 'returns truthy' do
        expect(subject.exists?).to be_truthy
      end
    end
  end
end
