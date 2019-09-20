require 'rails_helper'

RSpec.describe FileManager do
  let(:file) { file_fixture('hello_world.txt') }
  let(:encoded_file) { Base64.strict_encode64(file.read) }
  let(:user_id) { SecureRandom.uuid }
  let(:service_token) { SecureRandom.hex }
  let(:service_slug) { 'service-slug' }
  let(:encrypted_user_id_and_token) { SecureRandom.hex(16) }
  let(:bucket) { ENV['AWS_S3_BUCKET_NAME'] }
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  let(:subject) do
    described_class.new(
      encoded_file: encoded_file,
      user_id: user_id,
      service_slug: service_slug,
      encrypted_user_id_and_token: encrypted_user_id_and_token,
      bucket: bucket
    )
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
        described_class.new(encoded_file: encoded_file,
                            user_id: user_id,
                            service_slug: service_slug,
                            encrypted_user_id_and_token: encrypted_user_id_and_token,
                            bucket: bucket,
                            options: { max_size: '1300' })
      end

      it 'returns true' do
        expect(subject.file_too_large?).to be_truthy
      end
    end

    context 'when file is within size limit' do
      subject do
        described_class.new(encoded_file: encoded_file,
                            user_id: user_id,
                            service_slug: service_slug,
                            encrypted_user_id_and_token: encrypted_user_id_and_token,
                            bucket: bucket,
                            options: { max_size: '1400' })
      end

      it 'returns false' do
        expect(subject.file_too_large?).to be_falsey
      end
    end
  end

  describe '#type_permitted?' do
    let(:file) { file_fixture('image.png') }

    before :each do
      subject.save_to_disk
    end

    context 'when file is permitted' do
      subject do
        described_class.new(encoded_file: encoded_file,
                            user_id: user_id,
                            service_slug: service_slug,
                            encrypted_user_id_and_token: encrypted_user_id_and_token,
                            bucket: bucket,
                            options: { allowed_types: ['image/png'] })
      end

      it 'returns true' do
        expect(subject.type_permitted?).to be_truthy
      end
    end

    context 'when file is not permitted' do
      subject do
        described_class.new(encoded_file: encoded_file,
                            user_id: user_id,
                            service_slug: service_slug,
                            encrypted_user_id_and_token: encrypted_user_id_and_token,
                            bucket: bucket,
                            options: { allowed_types: ['plain/text'] })
      end

      it 'returns false' do
        expect(subject.type_permitted?).to be_falsey
      end
    end
  end

  describe '#has_virus?' do
    context 'when file has a virus' do
      it 'returns true' do
        allow_any_instance_of(MalwareScanner).to receive(:virus_found?).and_return(true)
        expect(subject.has_virus?).to be_truthy
      end
    end

    context 'when files does not have a virus' do
      it 'returns false' do
        allow_any_instance_of(MalwareScanner).to receive(:virus_found?).and_return(false)
        expect(subject.has_virus?).to be_falsey
      end
    end
  end

  after :each do
    FileUtils.rm(Dir.glob('tmp/files/quarantine/*'), force: true)
  end
end
