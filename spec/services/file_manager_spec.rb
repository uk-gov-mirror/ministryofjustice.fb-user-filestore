require 'rails_helper'

RSpec.describe FileManager do
  let(:file) { file_fixture('hello_world.txt') }
  let(:encoded_file) { Base64.strict_encode64(file.read) }
  let(:user_id) { SecureRandom.uuid }
  let(:service_token) { SecureRandom.hex }
  let(:service_slug) { 'service-slug' }
  let(:encrypted_user_id_and_token) { SecureRandom.hex(16) }

  subject do
    described_class.new(encoded_file: encoded_file,
                        user_id: user_id,
                        service_slug: service_slug,
                        encrypted_user_id_and_token: encrypted_user_id_and_token)
  end

  describe '#key' do
    before :each do
      allow(ServiceTokenService).to receive(:get).with('service-slug')
                                                 .and_return('service-token')
    end

    it 'expect file to be saved to disk' do
      subject.save_to_disk
      subject.upload

      encrypted_data = Cryptography.new(file: File.open(file).read).encrypt
      expect(File.open("tmp/files/#{subject.send(:key)}").read).to eql(encrypted_data)
    end
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
                            options: { allowed_types: ['plain/text'] })
      end

      it 'returns false' do
        expect(subject.type_permitted?).to be_falsey
      end
    end
  end

  after :each do
    FileUtils.rm(Dir.glob('tmp/files/quarantine/*'), force: true)
  end
end
