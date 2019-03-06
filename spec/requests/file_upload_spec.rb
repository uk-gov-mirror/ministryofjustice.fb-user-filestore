require 'rails_helper'
require 'base64'
require 'pry'

describe 'FileUpload API', type: :request do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  describe 'a POST /service/{service_slug}/{user_id} request' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    after do
      FileUtils.rm('tmp/files/quarantine/*', force: true)
    end

    describe 'upload with JSON payload' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      around :each do |example|
        Timecop.freeze(Time.utc(2019, 1, 1)) do
          example.run
        end
      end

      before do
        Storage::Disk::Uploader.purge_destination!

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 201' do
        expect(response).to have_http_status(201)
      end

      it 'saves the decoded data to a local file in quarantine' do
        path_to_file = controller.instance_variable_get(:@file_manager).path_to_file
        decoded_data = File.open(path_to_file).read
        expect(file).to eq(decoded_data)
      end

      it 'saves the decoded data to a local file' do
        path_to_file = "./tmp/files/#{controller.instance_variable_get(:@file_manager).send(:key)}"
        decoded_data = File.open(path_to_file).read
        expect(file).to eq(decoded_data)
      end

      it 'returns correct json response' do
        body = JSON.parse(response.body)

        expect(body['url']).to eql('/service/service-slug/user/user-id/a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
        expect(body['size']).to eql(11)
        expect(body['type']).to eql('text/plain')
        expect(body['date']).to eql(1546300800)
      end

      describe 'uploading the same file again' do
        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'returns 204 no content' do
          expect(response.status).to eql(204)
        end
      end
    end

    describe 'file exceeds max file size' do
      let(:file) { file_fixture('sample.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      before do
        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      context 'returns error if file size is too large' do
        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid.too-large content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('invalid.too-large')
        end
      end
    end

    describe 'Mime type of file is not supported' do
      describe 'bmp format' do
        let(:file) { file_fixture('bitmap.bmp').read }
        let(:encoded_file) { Base64.encode64(file) }
        let(:json) { json_format(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('invalid type')
        end
      end

      describe 'html format' do
        let(:file) { file_fixture('hello.html').read }
        let(:encoded_file) { Base64.encode64(file) }
        let(:json) { json_format(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('invalid type')
        end
      end
    end

    describe 'file could not be saved to quarantine' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      let(:file_manager) { double('file_manager') }

      it 'returns relevant error' do
        allow(FileManager).to receive(:new).and_return(file_manager)
        allow(file_manager).to receive(:save_to_disk).and_raise(Errno::ENOSPC.new)

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers

        body = JSON.parse(response.body)
        expect(body['code']).to eql(503)
        expect(body['name']).to eql('unavailable.file-store-failed')
      end
    end
  end

  def json_format(encoded_file)
    {
        "iat": '{timestamp}',
        "encrypted_user_id_and_token": 'abcdefghijklmnopqrstuvwxyz012345',
        "file": encoded_file,
        "policy": {
          "allowed_types": %w[
            text/plain
            application/vnd.openxmlformats-officedocument.wordprocessingml.document
            application/msword
            application/vnd.oasis.opendocument.text
            application/pdf
            image/jpeg
            image/png
            application/vnd.ms-excel
          ],
          "max_size": '10240',
          "expires": '28d'
        }
    }
  end
end
