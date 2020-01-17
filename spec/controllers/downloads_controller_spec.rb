require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  describe 'GET #show' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:payload_query_string) do
      json = query_string_payload.to_json
      base64 = Base64.strict_encode64(json)
    end

    context 'when there are missing paramters' do
      context 'missing payload' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: 'abc', fingerprint_with_prefix: '28d-fingerprint' }
          get :show, params: url_params
          expect(response).to be_forbidden
        end
      end

      context 'missing encrypted_user_id_and_token' do
        let(:payload_query_string) do
          json = {}.to_json
          base64 = Base64.strict_encode64(json)
        end

        it 'returns error' do
          url_params = { service_slug: 'service-slug',
                         user_id: 'abc',
                         fingerprint_with_prefix: '28d-fingerprint',
                         payload: payload_query_string }
          get :show, params: url_params
          expect(response).to be_forbidden
        end
      end
    end
  end
end
