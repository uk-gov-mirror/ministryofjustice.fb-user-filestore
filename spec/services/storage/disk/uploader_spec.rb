require 'rails_helper'

RSpec.describe Storage::Disk::Uploader do
  let(:path) { file_fixture('lorem_ipsum.txt') }
  let(:key) { '28d/service-slug/upload-fingerprint' }

  subject do
    described_class.new(path: path, key: key)
  end

  describe '#upload' do
    describe do
      it 'saves files to disk' do
        expect(subject.exists?).to be_falsey
        subject.upload
        expect(subject.exists?).to be_truthy
      end
    end

    before :each do
      FileUtils.rm_r(Dir.glob('tmp/files/*'))
    end
  end
end
