require 'rails_helper'

RSpec.describe 'POST /presigned-s3-url', type: :request do
  include KeyHelpers

  let(:service_slug) { 'my-service' }
  let(:user_identifier) { SecureRandom::uuid }
  let(:fingerprint_with_prefix) do
    '28d-aaa59621acecd4b1596dd0e96968c6cec3fae7927613a12c357e7a62e1187aaa'
  end
  let(:headers) do
    {
      'content-type' => 'application/json',
      'X-Encrypted-User-Id-And-Token' => '12345678901234567890123456789012'
    }
  end
  let(:url) { "/service/#{service_slug}/user/#{user_identifier}/#{fingerprint_with_prefix}/presigned-s3-url" }
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  before do
    allow_any_instance_of(Adapters::ServiceTokenCacheClient).to receive(:public_key_for).and_return(public_key)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    s3.stub_responses(:get_object, { body: file_fixture('encrypted_file').read })
    s3.stub_responses(:put_object, {})
  end

  it 'responds with a 201 created' do
    post url, params: {}.to_json, headers: headers
    expect(response.status).to eq(201)
  end

  it 'downloads the file from S3' do
    expect(s3).to receive(:get_object).once
    post url, params: {}.to_json, headers: headers
  end

  it 'uploads a re-encrypted file to S3' do
    expect(s3).to receive(:put_object)
    post url, params: {}.to_json, headers: headers
  end

  it 'returns an encryption a URL, init vector and key' do
    post url, params: {}.to_json, headers: headers
    expect(JSON.parse(response.body).keys).to eq(["url", "encryption_key", "encryption_iv"])
  end

  it 'includes an S3 url' do
    post url, params: {}.to_json, headers: headers
    expect(URI.parse(JSON.parse(response.body)["url"]).host).to include('s3')
  end

  context 'when decrypting the file reencrypted in S3' do
    let(:original_file_decrypted) do
      Cryptography.new(
        encryption_key: ENV.fetch('ENCRYPTION_KEY'),
        encryption_iv: ENV.fetch('ENCRYPTION_IV')
      ).decrypt(file: file_fixture('encrypted_file').read)
    end
    let(:s3_put_request) do
      s3.api_requests.find{|a| a[:operation_name] == :put_object}
    end
    let(:reencrypted_file_data) { s3_put_request[:params][:body] }

    before do
      post url, params: {}.to_json, headers: headers
    end

    it 'can decrypt the reencrypted file with the returned keys' do
      parsed_response = JSON.parse(response.body)
      decrypted_file_data = Cryptography.new(
        encryption_key: Base64.strict_decode64(parsed_response["encryption_key"]),
        encryption_iv: Base64.strict_decode64(parsed_response["encryption_iv"])
      ).decrypt(file: reencrypted_file_data)

      expect(decrypted_file_data).to eq(original_file_decrypted)
    end
  end
end
