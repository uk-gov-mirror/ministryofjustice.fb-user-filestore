require 'rails_helper'

RSpec.describe UploadsController, type: :controller do
  let(:headers) {
    {
      'content-type' => 'application/json',
      'x-access-token-v2' => jwt
    }
  }
  let(:file) { file_fixture('hello_world.txt').read }
  let(:encoded_file) { Base64.strict_encode64(file) }
  let(:json) { json_request(encoded_file) }
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:service_slug) { 'service-slug' }
  let(:fake_service) { ServiceTokenService.new(service_slug: service_slug) }
  let(:user_id) { 'user-guid' }
  let(:jwt) { JWT.encode({sub: user_id, iat: Time.current.to_i}, private_key, 'RS256') }
  let(:encoded_private_key) { 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBM1NUQjJMZ2gwMllrdCtMcXo5bjY5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlCmx6MXh4cEpPTGV0ckxncW4zN2hNak5ZMC9uQUNjTWR1RUg5S1hycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW4KYmRtKzZzNUt2TGdVTk43WFZjZVA5UHVxWnlzeENWQTRUbm1MRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdApQYkFneFdBZmVTTGxiN0JQbHNIbS9IMEFBTCtuYmFPQ2t3dnJQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05aCnNUVlFhbzRYd2hlYnVkaGx2TWlrRVczMldLZ0t1SEhXOHpkdlU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0wKQTNZaDhMSTVHeWQ5cDZmMjdNZmxkZ1VJSFN4Y0pweTFKOEFQcXdJREFRQUJBb0lCQUU5ZjJTQVRmemlraWZ0aQp2RXRjZnlMN0EzbXRKd2c4dDI2cDcyT3czMUg0RWg4NHlOaWFHbE5ld2lialAvWW5wdmU2NitjRkg4SlBxK0NWCkJHRnhmdDBmampXZkRrZTNiTTVaUjdaQUVDaW8vay9pMEpveU5MK015ZkNRMWRmZ1FFUXV1L0gvdnJzSEdyT3cKRW5YQVZIUzg1enlCWWczbjM4QmxjVkw4V2s4R3FlMGxCUU5RSks5dSt5ckc5NEpoUTVoMTZubXlyQ0xpWkhSTAoyWS94MTdDL3BCN1VlUVFWeDZ4aVZSdVdmT1FoWlNmT2IzRHpsYldhc2owa2pTaHdWWDFQVG5sU0lxQXo5T3krClY5M013VFBtbVNOOGFiL0pGVlVBUzhtckM2elcxc0NjcFVUTFZHRVZBUFBJcWpjMmZFKzdLVGNjVDFzWkt0MWIKb2p1R2xSa0NnWUVBL2ZuK3VZcCtxSzdiQmxkUTZCSmNsNXpkR0xybXRrWFFZR096d2cvN21zd0NVdUM3UFpGYQpJV0xBSGM4QU85eDZvUFQ0SzFPNnQzYVBtMW8vUTR1S1N2NWNGK3EwaThMemVQM2JxdnowQXBXekdPVFdiMXg5CnNBRzNIOCtIT3JNS0NXVWl3bm5pUG1PMDNXUUY0dmFoWUd1WXYzSkNSNTYxanBJOFRkMkx6QmNDZ1lFQTN1ZkwKKzdqNGE2elVBOUNrak5wSnB2VkxyQk8ydUpiRHk5NXBpSzlCU3FIellQSEw3VVBWTExFaXRGWlNBWlRWRzFHMwpWbUNxMVoraXhCcTRST0t2VldyME1mSklsUlEvQXBQY3NwVXJjRTRPcnAxRkEyNjlLdXhhdnI5dmpLMCtIbWNRClEydWNRWWdUeWFXQlNZeW9laW04QWQ2UlpJRzVLQ25uTVlhNThZMENnWUVBNUp6VG5VLzlFdm5TVGJMck1QclcKUGVNRlllMWJIMWRZYW10VXM2cVBZSmVpdjlkcXM5RFN3SnFUTkVIUWhCSENrSC94bzQ2SzAvbjA2bkloNERzTApFTlpGTDRJbFltanBvRTlpSEZmMWpSNFRTS1UwSUttd3VXM1IyT0NGYVdFZjk3VUJ4T3pScWpjMTV0TFNPYXFuCk9KT2h1ekt1VnFtVjQrL2VPSGprRGFFQ2dZQUdMVFloeTRaV3RYdEtmOFdQZ1p6NDIyTTFhWFp1dHY3Rjcydk4KTmM0QlcydDdERGd5WXViTlRqcy85QVJodHRZUTQ3ckkwZlRwNW5xRUpKbG1qMEY4aEhJdjBCN2l3cVRjVld5UQpKa0lGNHFQVmd0WWV1anJUcmFqMkVDZnZKZjNLcWVCeGZkSGVudjZ0WDhDdFlSQnFFaTM3ZjBkWUdhQWYxTWxyClBlaDVJUUtCZ1FDbmN6YU8xcUx3VktyeUc4TzF5ZUhDSjQzT1h6SENwN3VnOE90aS9ScmhWZ08wSCtEdVpXUzUKSWhydHpUeU56MExyQTdibVFLTWZ4Y3k5Y29LOG9zZnVma1pZenJxM1ZFa0ViUCtjRWdLcGtlTDlaY2RSbXZ3WQozSTZkMUlOWVUwMldPSzhiRUJBNElJNGc0ak9ZcjJJUjFzb2lWZ0E2YnVya3E3QnMrUm41WFE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=' }
  let(:private_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_private_key)) }
  let(:encoded_public_key) { 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEzU1RCMkxnaDAyWWt0K0xxejluNgo5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlbHoxeHhwSk9MZXRyTGdxbjM3aE1qTlkwL25BQ2NNZHVFSDlLClhycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW5iZG0rNnM1S3ZMZ1VOTjdYVmNlUDlQdXFaeXN4Q1ZBNFRubUwKRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdFBiQWd4V0FmZVNMbGI3QlBsc0htL0gwQUFMK25iYU9Da3d2cgpQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05ac1RWUWFvNFh3aGVidWRobHZNaWtFVzMyV0tnS3VISFc4emR2ClU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0xBM1loOExJNUd5ZDlwNmYyN01mbGRnVUlIU3hjSnB5MUo4QVAKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==' }
  let(:public_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_public_key)) }
  let(:fake_service) { double(:service, get: 'service-token') }
  let(:fake_service_with_no_token) { double(:service) }

  before do
    allow(ServiceTokenService).to receive(:new).with(service_slug: '').and_return(fake_service)
    allow(ServiceTokenService).to receive(:new).with(service_slug: service_slug).and_return(fake_service)
    allow(fake_service).to receive(:public_key).and_return(public_key)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    request.headers.merge!(headers)
  end

  describe 'POST #create' do
    context 'when there are missing paramters' do
      before :each do
        disable_malware_scanner!
      end

      context 'missing file' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
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
          url_params = { service_slug: '', user_id: user_id }
          json_params = json
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing encrypted_user_id_and_token' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
          json_params = json
          json_params.delete(:encrypted_user_id_and_token)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_forbidden
        end
      end

      context 'missing policy' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
          json_params = json
          json_params.delete(:policy)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing policy.max_size' do
        it 'returns error' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
          json_params = json
          json_params[:policy].delete(:max_size)
          post :create, params: url_params.merge(json_params)
          expect(response).to be_bad_request
        end
      end

      context 'missing policy.allowed_types' do
        it 'defaults to ["*/*"]' do
          disable_malware_scanner!

          url_params = { service_slug: 'service-slug', user_id: user_id }
          json_params = json
          json_params[:policy].delete(:allowed_types)
          post :create, params: url_params.merge(json_params)
          expect(controller.params[:policy][:allowed_types]).to eql(['*/*'])
          expect(response).to be_successful
        end
      end

      context 'empty policy.allowed_types' do
        it 'defaults to ["*/*"]' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
          json_params = json
          json_params[:policy][:allowed_types] = []
          post :create, params: url_params.merge(json_params)
          expect(controller.params[:policy][:allowed_types]).to eql(['*/*'])
          expect(response).to be_successful
        end
      end

      context 'missing policy.expires' do
        it 'defaults to 28 as integer' do
          url_params = { service_slug: 'service-slug', user_id: user_id }
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
        url_params = { service_slug: 'service-slug', user_id: user_id }
        json_params = json
        post :create, params: url_params.merge(json_params)
        expect(response.status).to eql(400)
      end

      it 'returns virus error message' do
        url_params = { service_slug: 'service-slug', user_id: user_id }
        json_params = json
        post :create, params: url_params.merge(json_params)

        hash = JSON.parse(response.body)

        expect(hash['code']).to eql(400)
        expect(hash['name']).to eql('invalid.virus')
      end
    end
  end
end
