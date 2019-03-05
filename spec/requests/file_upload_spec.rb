require 'rails_helper'
require 'base64'
require 'pry'

describe 'FileUpload API', type: :request do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  describe 'a POST /service/{service_slug}/{user_id} request' do
    before do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/service/service-slug/user/user-id', :params => json.to_json, :headers => headers
    end

    after do
      FileUtils.rm('tmp/files/quarantine/*', force: true)
    end

    describe 'upload with JSON payload' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      it 'has status 200' do
        expect(response).to have_http_status(200)
      end

      it 'saves the decoded data to a local file' do
        filename = controller.send(:random_filename)
        decoded_data = File.open("tmp/files/quarantine/#{filename}").read
        expect(file).to eq(decoded_data)
      end
    end

    describe 'file exceeds max file size' do
      let(:file) { file_fixture('sample.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

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

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('invalid type')
        end
      end
    end
  end

  describe 'a GET /service/{service_slug}/{user_id}/{fingerprint} request' do
    before do
      get '/service/service-slug/user/user-id/fingerprint'
    end

    describe 'Add header to response header' do
      it 'sets the {encrypted_user_id and token} as a x-header' do
        expect(response.headers['x-access-token']).to eq('ENCRYPTED_USER_ID + TOKEN')
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
