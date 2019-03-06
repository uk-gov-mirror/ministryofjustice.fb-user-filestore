require 'rails_helper'

describe 'file download', type: :request do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  describe 'GET /service/{service_slug}/{user_id}/{fingerprint} request' do
    before do
      get '/service/service-slug/user/user-id/fingerprint'
    end

    context 'when file does exist' do
      around :each do |example|
        FileUtils.cp(file_fixture('hello_world.txt'), Rails.root.join('tmp/files/28d/3bba5a1694c27d3d3749a2ed96b0dd289bc56c37d145a8fee476f695c98db260'))
        example.run
        FileUtils.rm(Rails.root.join('tmp/files/28d/3bba5a1694c27d3d3749a2ed96b0dd289bc56c37d145a8fee476f695c98db260'))
      end

      it 'returns status 200' do
        expect(response).to be_successful
      end

      it 'returns correct json' do
        hash = JSON.parse(response.body)
        expect(hash['file']).to eql(Base64.encode64('Hello World'))
      end
    end

    context 'when file does not exist' do
      it 'returns status 404' do
        expect(response).to be_not_found
      end

      it 'returns correct json' do
        hash = JSON.parse(response.body)
        expect(hash['code']).to eql(404)
        expect(hash['name']).to eql('not-found')
      end
    end
  end
end
