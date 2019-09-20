require 'rails_helper'

RSpec.describe UploadsController, type: :controller do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:file) { file_fixture('hello_world.txt').read }
  let(:encoded_file) { Base64.strict_encode64(file) }
  let(:json) { json_request(encoded_file) }
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  before :each do
    allow_any_instance_of(UploadsController).to receive(:verify_token!)
    allow(ServiceTokenService).to receive(:get).and_return('service-token')
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  describe 'POST #create' do
    context 'when there are missing paramters' do
      before :each do
        disable_malware_scanner!
      end

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
          expect(response).to be_forbidden
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
          disable_malware_scanner!

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

    context 'when file has a virus' do
      before :each do
        allow_any_instance_of(FileManager).to receive(:has_virus?).and_return(true)
      end

      it 'returns a 400' do
        url_params = { service_slug: 'service-slug', user_id: 'abc' }
        json_params = json
        post :create, params: url_params.merge(json_params)
        expect(response.status).to eql(400)
      end

      it 'returns virus error message' do
        url_params = { service_slug: 'service-slug', user_id: 'abc' }
        json_params = json
        post :create, params: url_params.merge(json_params)

        hash = JSON.parse(response.body)

        expect(hash['code']).to eql(400)
        expect(hash['name']).to eql('invalid.virus')
      end
    end
  end
end
