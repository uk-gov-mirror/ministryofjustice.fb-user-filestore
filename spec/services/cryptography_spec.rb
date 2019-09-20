require 'rails_helper'

RSpec.describe Cryptography do
  let(:encryption_key) { ENV['ENCRYPTION_KEY'] }
  let(:encryption_iv) { ENV['ENCRYPTION_IV'] }
  let(:cryptography) do
    Cryptography.new(
      encryption_key: encryption_key,
      encryption_iv: encryption_iv
    )
  end

  describe '#encrypt' do
    let(:file) { file_fixture('lorem_ipsum.txt').read }
    let(:encrypted_data) { cryptography.encrypt(file: file) }
    let(:data) { 'ce030d6aac29d4a5a8b03f7428ff4626' }

    it 'changes the file content using AES-256 encryption' do
      expect(encrypted_data).to_not eq(file)
      expect(encrypted_data).to eq(data)
    end
  end

  describe '#decrypt' do
    let(:plain_text_file) { file_fixture('lorem_ipsum.txt').read }

    before do
      encrypted_file = cryptography.encrypt(file: plain_text_file)
      file = File.open('spec/fixtures/files/encrypted_file', 'wb')
      file.write(encrypted_file)
      file.close
    end

    let(:file) { file_fixture('encrypted_file').read }
    let(:decrypted_data) { cryptography.decrypt(file: file) }

    it 'converts encrypted data back to plain text' do
      expect(decrypted_data).to eq(plain_text_file)
    end
  end
end
