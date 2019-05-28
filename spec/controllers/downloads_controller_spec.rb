require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    allow(ServiceTokenService).to receive(:get).and_return('service-token')
  end

  describe 'GET #show' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    context 'missing encrypted_user_id_and_token' do
      it 'returns error' do
        url_params = { service_slug: 'service-slug',
                       user_id: 'abc',
                       fingerprint_with_prefix: '28d-fingerprint' }
        get :show, params: url_params
        expect(response).to be_forbidden
      end
    end
  end
end
