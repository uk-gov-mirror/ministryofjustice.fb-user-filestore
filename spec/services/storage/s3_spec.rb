require 'rails_helper'

RSpec.describe Storage::S3 do
  let(:path) do
    file_fixture('lorem_ipsum.txt')
  end

  subject do
    described_class.new(path: path)
  end

  describe '#upload' do
    it 'uploads file to s3' do
      expect(subject.exists?).to be_falsey
      subject.upload
      expect(subject.exists?).to be_truthy
    end

    after :each do
      subject.purge!
    end
  end

  describe '#download' do
    it 'downloads file from s3' do
      subject.upload
      subject.download

      downloaded_path = subject.send(:temp_file).path

      contents = File.open(downloaded_path).read

      expect(contents).to eql("lorem ipsum\n")
    end

    after :each do
      subject.purge!
      subject.send(:temp_file).unlink
    end
  end
end
