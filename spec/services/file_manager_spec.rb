require 'rails_helper'

RSpec.describe FileManager do
  let(:file) { file_fixture('hello_world.txt') }
  let(:encoded_file) { Base64.encode64(file.read) }

  subject do
    described_class.new(encoded_file)
  end

  describe '#save_to_disk' do
    let(:filename) { subject.send(:random_filename) }

    it 'expect file to be saved to disk' do
      expect(File.exists?("tmp/files/quarantine/#{filename}")).to be_falsey
      subject.save_to_disk
      expect(File.exists?("tmp/files/quarantine/#{filename}")).to be_truthy
    end
  end

  describe '#file_too_large?' do
  let(:file) { file_fixture('bitmap.bmp') } # ~1.3kb

    before :each do
      subject.save_to_disk
    end

    context 'when file is too large' do
      subject do
        described_class.new(encoded_file, max_size: '1300')
      end

      it 'returns true' do
        expect(subject.file_too_large?).to be_truthy
      end
    end

    context 'when file is within size limit' do
      subject do
        described_class.new(encoded_file, max_size: '1400')
      end

      it 'returns false' do
        expect(subject.file_too_large?).to be_falsey
      end
    end
  end

  after :each do
    FileUtils.rm(Dir.glob('tmp/files/quarantine/*'), force: true)
  end
end
