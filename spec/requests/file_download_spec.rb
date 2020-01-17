require 'rails_helper'

RSpec.describe 'GET /service/{service_slug}/user/{user_id}/{fingerprint}', type: :request do

  let(:headers) do
    { "X-Encrypted-User-Id-And-Token" => '12345678901234567890123456789012' }
  end
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:do_get!) do
    get "/service/service-slug/user/user-id/28d-fingerprint", headers: headers
  end
  let(:fake_service) { ServiceTokenService.new(service_slug: 'service-slug') }

  around :each do |example|
    reset_test_directories!
    example.run
  end

  before :each do
    allow(ServiceTokenService).to receive(:new).with(service_slug: 'service-slug').and_return(fake_service)
    allow(fake_service).to receive(:get).and_return('service-token')
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  context 'when file exists' do
    before do
      s3.stub_responses(:head_object, {})
      s3.stub_responses(:get_object, { body: file_fixture('encrypted_file').read })
    end

    it 'returns status 200' do
      do_get!
      expect(response).to be_successful
    end

    it 'returns file' do
      do_get!
      expect(response.body).to eql("lorem ipsum\n")
    end
  end

  context 'when file does not exist' do
    before do
      s3.stub_responses(:head_object, 'NotFound')
    end

    it 'returns status 404' do
      do_get!
      expect(response).to be_not_found
    end

    it 'returns correct json' do
      do_get!
      hash = JSON.parse(response.body)
      expect(hash['code']).to eql(404)
      expect(hash['name']).to eql('not-found')
    end
  end

  context 'when there is a problem' do
    it 'returns 503' do
      downloader = double('downloader', exists?: true)
      allow(Storage::S3::Downloader).to receive(:new).and_return(downloader)
      allow(downloader).to receive(:contents).and_raise(StandardError.new)

      do_get!

      expect(response.status).to eql(503)
    end
  end
end
