require 'rails_helper'

describe 'FileUpload API', type: :request do
  describe 'a POST /service/{service_slug}/{user_id} request' do
    before do
      post "/service/service-slug/user/user-id"
    end

    describe 'the response' do
      it 'has status 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
