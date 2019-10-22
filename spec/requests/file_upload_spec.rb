require 'rails_helper'
require 'base64'

RSpec.describe 'FileUpload API', type: :request do
  around :each do |example|
    reset_test_directories!

    example.run
  end

  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  before :each do
    disable_malware_scanner!
    allow_any_instance_of(UploadsController).to receive(:verify_token!)
    allow(ServiceTokenService).to receive(:get).with('service-slug')
      .and_return('service-token')
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  describe 'a POST /service/{service_slug}/user/{user_id} request' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    context 'with a correct JSON payload' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }
      let(:now) { Time.now.utc }

      around :each do |example|
        Timecop.freeze(now) do
          example.run
        end
      end

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: now)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns correct json response' do
        body = JSON.parse(response.body)

        expect(body['fingerprint']).to eql('28d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
        expect(body['size']).to eql(11)
        expect(body['type']).to eql('text/plain')
        expect(body['date']).to be_within(2.hours).of((now + 28.days).to_i)
      end

      it 'deletes quarantined file' do
        path_to_file = controller.instance_variable_get(:@file_manager).path_to_file
        expect(File.exist?(path_to_file)).to be_falsey
      end

      context 'when uploading the same file again' do
        before do
          s3.stub_responses(:head_object, {}, Aws::S3::Types::HeadObjectOutput.new(last_modified: now) )

          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'returns 200' do
          expect(response).to be_ok
        end

        it 'returns response with fingerprint and metadata' do
          body = JSON.parse(response.body)

          expect(body['fingerprint']).to eql('28d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
          expect(body['size']).to eql(11)
          expect(body['type']).to eql('text/plain')
          expect(body['date']).to be_within(2.hours).of((now + 28.days).to_i)
        end
      end
    end

    context 'when file exceeds max file size' do
      let(:file) { file_fixture('sample.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: Time.now.utc)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns JSON with invalid.too-large content' do
        result = JSON.parse(response.body)
        expect(result['name']).to eq('invalid.too-large')
      end
    end

    context 'When mime type of file is not supported' do
      context 'when file is bmp format' do
        let(:file) { file_fixture('bitmap.bmp').read }
        let(:encoded_file) { Base64.strict_encode64(file) }
        let(:json) { json_request(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('accept')
        end
      end

      context 'when file is html format' do
        let(:file) { file_fixture('hello.html').read }
        let(:encoded_file) { Base64.strict_encode64(file) }
        let(:json) { json_request(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('accept')
        end
      end
    end

    context 'when file cannot be saved to quarantine' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }

      let(:file_manager) { double('file_manager', delete_file: true) }

      it 'returns relevant error' do
        allow(FileManager).to receive(:new).and_return(file_manager)
        allow(file_manager).to receive(:save_to_disk).and_raise(Errno::ENOSPC.new)

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers

        body = JSON.parse(response.body)
        expect(body['code']).to eql(503)
        expect(body['name']).to eql('unavailable.file-store-failed')
      end
    end

    context 'with custom expires option set' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file, expires: 7) }
      let(:now) { Time.now.utc }

      around :each do |example|
        Timecop.freeze(now) do
          example.run
        end
      end

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: Time.now.utc)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns correct json response' do
        body = JSON.parse(response.body)

        expect(body['fingerprint']).to eql('7d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
        expect(body['size']).to eql(11)
        expect(body['type']).to eql('text/plain')
        expect(body['date']).to be_within(1.hour).of((now + 7.days).to_i)
      end

      it 'deletes quarantined file' do
        path_to_file = './tmp/files/quarantine/7d/4d91e82727bdca3f0496f84e90d6ee94d81767b661683e1396aefffe4d55a2cd'
        expect(File.exist?(path_to_file)).to be_falsey
      end
    end
  end
end
