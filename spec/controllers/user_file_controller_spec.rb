require 'rails_helper'

RSpec.describe UserFileController, type: :controller do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  describe 'POST #create' do
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:file) { file_fixture('hello_world.txt').read }
    let(:encoded_file) { Base64.encode64(file) }
    let(:json) { json_request(encoded_file, allowed_types: []) }

    describe 'when allowed types is empty' do
      let(:logger) { double('logger') }

      before :each do
        request.headers.merge! headers
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'logs warning' do
        expect(logger).to receive(:warn)

        url_params = { service_slug: 'service-slug', user_id: 'abc' }
        json_params = json
        post :create, params: url_params.merge(json_params)
      end
    end
  end
end
