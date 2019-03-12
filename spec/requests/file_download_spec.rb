require 'rails_helper'

RSpec.describe 'file download', type: :request do
  around :each do |example|
    reset_test_directories!

    example.run
  end

  let(:payload) do
    {
      encrypted_user_id_and_token: '12345678901234567890123456789012',
      iat: Time.now.to_i
    }
  end

  let(:headers) do
    { "X-Access-Token" => JWT.encode(payload, 'service-token', 'HS256') }
  end

  # Buffer.from(JSON.stringify(payload)).toString('Base64')
  let(:payload_query_string) do
    json = payload.to_json
    base64 = Base64.strict_encode64(json)
  end

  before :each do
    allow(ServiceTokenService).to receive(:get).with('service-slug')
                                               .and_return('service-token')
  end

  describe 'GET /service/{service_slug}/user/{user_id}/{fingerprint}' do
    let(:do_get!) do
      get "/service/service-slug/user/user-id/28d-fingerprint?payload=#{payload_query_string}", headers: headers
    end

    context 'when file does exist' do
      around :each do |example|
        FileUtils.cp(file_fixture('hello_world.txt'), Rails.root.join('tmp/files/28d/6ac6a2fe8dc936178d165c6ddffa39737b7fbb5dfdf17bbf81d2ac7418820a46'))
        example.run
        FileUtils.rm(Rails.root.join('tmp/files/28d/6ac6a2fe8dc936178d165c6ddffa39737b7fbb5dfdf17bbf81d2ac7418820a46'))
      end

      it 'returns status 200' do
        do_get!
        expect(response).to be_successful
      end

      it 'returns correct json' do
        do_get!
        hash = JSON.parse(response.body)
        expect(hash['file']).to eql(Base64.strict_encode64('Hello World'))
      end

      it 'removes the temporary file' do
        do_get!
        downloader = controller.send(:downloader)
        expect(File.exist?(downloader.file.path)).to be_falsey
      end
    end

    context 'when file does not exist' do
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
        downloader = double('downloader', exists?: true, encoded_contents: '')
        allow(Storage::Disk::Downloader).to receive(:new).and_return(downloader)
        allow(downloader).to receive(:encoded_contents).and_raise(StandardError.new)

        do_get!

        expect(response.status).to eql(503)
      end
    end
  end
end
