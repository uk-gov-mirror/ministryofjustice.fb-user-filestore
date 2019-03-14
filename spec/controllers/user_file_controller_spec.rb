require 'rails_helper'

RSpec.describe UserFileController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    allow(ServiceTokenService).to receive(:get).and_return('service-token')
  end

  describe 'POST #create' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:file) { file_fixture('hello_world.txt').read }
    let(:encoded_file) { Base64.strict_encode64(file) }
    let(:json) { json_request(encoded_file) }

    context 'when there are missing paramters' do
      context 'missing file' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params.delete(:file)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing user_id' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: '' }
          json_params = json
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing service_slug' do
        it 'returns error' do
          url_params = { service_slug: '', user_id: 'abc' }
          json_params = json
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing encrypted_user_id_and_token' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params.delete(:encrypted_user_id_and_token)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing policy' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params.delete(:policy)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing policy.max_size' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params[:policy].delete(:max_size)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing policy.allowed_types' do
        it 'defaults to ["*/*"]' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params[:policy].delete(:allowed_types)
          post :create, params: url_params.merge(json_params)
          expect(controller.params[:policy][:allowed_types]).to eql(['*/*'])
          expect(response).to be_successful
        end
      end

      context 'empty policy.allowed_types' do
        it 'defaults to ["*/*"]' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params[:policy][:allowed_types] = []
          post :create, params: url_params.merge(json_params)
          expect(controller.params[:policy][:allowed_types]).to eql(['*/*'])
          expect(response).to be_successful
        end
      end

      context 'missing policy.expires' do
        it 'defaults to 28 as integer' do
          url_params = { service_slug: 'service-slug', user_id: 'abc' }
          json_params = json
          json_params[:policy].delete(:expires)
          post :create, params: url_params.merge(json_params)
          expect(controller.params[:policy][:expires]).to eql(28)
          expect(response).to be_successful
        end
      end
    end
  end

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
          expect(response).to be_bad_request
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
          expect(response).to be_bad_request
        end
      end
    end
  end
end
