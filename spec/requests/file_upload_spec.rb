require 'rails_helper'
require 'base64'
require 'pry'

describe 'FileUpload API', type: :request do
  describe 'a POST /service/{service_slug}/{user_id} request' do
    describe 'upload with JSON payload' do
      let(:file) { file_fixture("hello_world.txt").read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) do
        {
            "iat": "{timestamp}",
            "encrypted_user_id_and_token": "{userId+userToken encrypted via AES-256 with the serviceToken as the key}",
            "file": encoded_file,
            "policy": {
                "allowed_types": [],
                "max_size": "1024",
                "expires": "28d"
            }
        }
      end

      before do
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/service/service-slug/user/user-id", :params => json.to_json, :headers => headers
      end

      it 'has status 200' do
        expect(response).to have_http_status(200)
      end

      it "reads content of uploaded file" do
        expect(response.body).to eq("Hello World")
      end
    end
  end
end
