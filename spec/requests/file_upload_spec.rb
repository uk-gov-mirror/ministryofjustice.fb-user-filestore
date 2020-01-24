require 'rails_helper'
require 'base64'

RSpec.describe 'FileUpload API', type: :request do
  around :each do |example|
    reset_test_directories!

    example.run
  end

  let(:headers) {
    {
      'content-type' => 'application/json',
      'x-access-token-v2' => jwt
    }
  }
  let(:user_id) { 'user-id' }
  let(:jwt) { JWT.encode({sub: user_id, iat: Time.current.to_i}, private_key, 'RS256') }
  let(:encoded_private_key) { 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBM1NUQjJMZ2gwMllrdCtMcXo5bjY5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlCmx6MXh4cEpPTGV0ckxncW4zN2hNak5ZMC9uQUNjTWR1RUg5S1hycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW4KYmRtKzZzNUt2TGdVTk43WFZjZVA5UHVxWnlzeENWQTRUbm1MRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdApQYkFneFdBZmVTTGxiN0JQbHNIbS9IMEFBTCtuYmFPQ2t3dnJQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05aCnNUVlFhbzRYd2hlYnVkaGx2TWlrRVczMldLZ0t1SEhXOHpkdlU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0wKQTNZaDhMSTVHeWQ5cDZmMjdNZmxkZ1VJSFN4Y0pweTFKOEFQcXdJREFRQUJBb0lCQUU5ZjJTQVRmemlraWZ0aQp2RXRjZnlMN0EzbXRKd2c4dDI2cDcyT3czMUg0RWg4NHlOaWFHbE5ld2lialAvWW5wdmU2NitjRkg4SlBxK0NWCkJHRnhmdDBmampXZkRrZTNiTTVaUjdaQUVDaW8vay9pMEpveU5MK015ZkNRMWRmZ1FFUXV1L0gvdnJzSEdyT3cKRW5YQVZIUzg1enlCWWczbjM4QmxjVkw4V2s4R3FlMGxCUU5RSks5dSt5ckc5NEpoUTVoMTZubXlyQ0xpWkhSTAoyWS94MTdDL3BCN1VlUVFWeDZ4aVZSdVdmT1FoWlNmT2IzRHpsYldhc2owa2pTaHdWWDFQVG5sU0lxQXo5T3krClY5M013VFBtbVNOOGFiL0pGVlVBUzhtckM2elcxc0NjcFVUTFZHRVZBUFBJcWpjMmZFKzdLVGNjVDFzWkt0MWIKb2p1R2xSa0NnWUVBL2ZuK3VZcCtxSzdiQmxkUTZCSmNsNXpkR0xybXRrWFFZR096d2cvN21zd0NVdUM3UFpGYQpJV0xBSGM4QU85eDZvUFQ0SzFPNnQzYVBtMW8vUTR1S1N2NWNGK3EwaThMemVQM2JxdnowQXBXekdPVFdiMXg5CnNBRzNIOCtIT3JNS0NXVWl3bm5pUG1PMDNXUUY0dmFoWUd1WXYzSkNSNTYxanBJOFRkMkx6QmNDZ1lFQTN1ZkwKKzdqNGE2elVBOUNrak5wSnB2VkxyQk8ydUpiRHk5NXBpSzlCU3FIellQSEw3VVBWTExFaXRGWlNBWlRWRzFHMwpWbUNxMVoraXhCcTRST0t2VldyME1mSklsUlEvQXBQY3NwVXJjRTRPcnAxRkEyNjlLdXhhdnI5dmpLMCtIbWNRClEydWNRWWdUeWFXQlNZeW9laW04QWQ2UlpJRzVLQ25uTVlhNThZMENnWUVBNUp6VG5VLzlFdm5TVGJMck1QclcKUGVNRlllMWJIMWRZYW10VXM2cVBZSmVpdjlkcXM5RFN3SnFUTkVIUWhCSENrSC94bzQ2SzAvbjA2bkloNERzTApFTlpGTDRJbFltanBvRTlpSEZmMWpSNFRTS1UwSUttd3VXM1IyT0NGYVdFZjk3VUJ4T3pScWpjMTV0TFNPYXFuCk9KT2h1ekt1VnFtVjQrL2VPSGprRGFFQ2dZQUdMVFloeTRaV3RYdEtmOFdQZ1p6NDIyTTFhWFp1dHY3Rjcydk4KTmM0QlcydDdERGd5WXViTlRqcy85QVJodHRZUTQ3ckkwZlRwNW5xRUpKbG1qMEY4aEhJdjBCN2l3cVRjVld5UQpKa0lGNHFQVmd0WWV1anJUcmFqMkVDZnZKZjNLcWVCeGZkSGVudjZ0WDhDdFlSQnFFaTM3ZjBkWUdhQWYxTWxyClBlaDVJUUtCZ1FDbmN6YU8xcUx3VktyeUc4TzF5ZUhDSjQzT1h6SENwN3VnOE90aS9ScmhWZ08wSCtEdVpXUzUKSWhydHpUeU56MExyQTdibVFLTWZ4Y3k5Y29LOG9zZnVma1pZenJxM1ZFa0ViUCtjRWdLcGtlTDlaY2RSbXZ3WQozSTZkMUlOWVUwMldPSzhiRUJBNElJNGc0ak9ZcjJJUjFzb2lWZ0E2YnVya3E3QnMrUm41WFE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=' }
  let(:private_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_private_key)) }
  let(:encoded_public_key) { 'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEzU1RCMkxnaDAyWWt0K0xxejluNgo5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlbHoxeHhwSk9MZXRyTGdxbjM3aE1qTlkwL25BQ2NNZHVFSDlLClhycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW5iZG0rNnM1S3ZMZ1VOTjdYVmNlUDlQdXFaeXN4Q1ZBNFRubUwKRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdFBiQWd4V0FmZVNMbGI3QlBsc0htL0gwQUFMK25iYU9Da3d2cgpQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05ac1RWUWFvNFh3aGVidWRobHZNaWtFVzMyV0tnS3VISFc4emR2ClU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0xBM1loOExJNUd5ZDlwNmYyN01mbGRnVUlIU3hjSnB5MUo4QVAKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==' }
  let(:public_key) { OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_public_key)) }

  let(:s3) { Aws::S3::Client.new(stub_responses: true) }
  let(:fake_service) { ServiceTokenService.new(service_slug: 'service-slug') }

  before :each do
    disable_malware_scanner!
    allow(ServiceTokenService).to receive(:new).with(service_slug: 'service-slug').and_return(fake_service)
    allow(fake_service).to receive(:get).and_return('service-token')
    allow(fake_service).to receive(:public_key).and_return(public_key)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
  end

  describe 'a POST /service/{service_slug}/user/{user_id} request' do
    context 'with a correct JSON payload' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }
      let(:now) { Time.now.utc }

      around :each do |example|
        Timecop.freeze(now) do
          example.run
        end
      end

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: now)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns correct json response' do
        body = JSON.parse(response.body)

        expect(body['fingerprint']).to eql('28d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
        expect(body['size']).to eql(11)
        expect(body['type']).to eql('text/plain')
        expect(body['date']).to be_within(2.hours).of((now + 28.days).to_i)
      end

      it 'deletes quarantined file' do
        path_to_file = controller.instance_variable_get(:@file_manager).path_to_file
        expect(File.exist?(path_to_file)).to be_falsey
      end

      context 'when uploading the same file again' do
        before do
          s3.stub_responses(:head_object, {}, Aws::S3::Types::HeadObjectOutput.new(last_modified: now) )

          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'returns 200' do
          expect(response).to be_ok
        end

        it 'returns response with fingerprint and metadata' do
          body = JSON.parse(response.body)

          expect(body['fingerprint']).to eql('28d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
          expect(body['size']).to eql(11)
          expect(body['type']).to eql('text/plain')
          expect(body['date']).to be_within(2.hours).of((now + 28.days).to_i)
        end
      end
    end

    context 'when file exceeds max file size' do
      let(:file) { file_fixture('sample.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: Time.now.utc)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns JSON with invalid.too-large content' do
        result = JSON.parse(response.body)
        expect(result['name']).to eq('invalid.too-large')
      end
    end

    context 'When mime type of file is not supported' do
      context 'when file is bmp format' do
        let(:file) { file_fixture('bitmap.bmp').read }
        let(:encoded_file) { Base64.strict_encode64(file) }
        let(:json) { json_request(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('accept')
        end
      end

      context 'when file is html format' do
        let(:file) { file_fixture('hello.html').read }
        let(:encoded_file) { Base64.strict_encode64(file) }
        let(:json) { json_request(encoded_file) }

        before do
          post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
        end

        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid type content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('accept')
        end
      end
    end

    context 'when file cannot be saved to quarantine' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file) }

      let(:file_manager) { double('file_manager', delete_file: true) }

      it 'returns relevant error' do
        allow(FileManager).to receive(:new).and_return(file_manager)
        allow(file_manager).to receive(:save_to_disk).and_raise(Errno::ENOSPC.new)

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers

        body = JSON.parse(response.body)
        expect(body['code']).to eql(503)
        expect(body['name']).to eql('unavailable.file-store-failed')
      end
    end

    context 'with custom expires option set' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.strict_encode64(file) }
      let(:json) { json_request(encoded_file, expires: 7) }
      let(:now) { Time.now.utc }

      around :each do |example|
        Timecop.freeze(now) do
          example.run
        end
      end

      before do
        s3.stub_responses(
          :head_object,
          'NotFound',
          Aws::S3::Types::HeadObjectOutput.new(last_modified: Time.now.utc)
        )
        s3.stub_responses(:put_object, {})

        post '/service/service-slug/user/user-id', params: json.to_json, headers: headers
      end

      it 'has status 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns correct json response' do
        body = JSON.parse(response.body)

        expect(body['fingerprint']).to eql('7d-a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e')
        expect(body['size']).to eql(11)
        expect(body['type']).to eql('text/plain')
        expect(body['date']).to be_within(1.hour).of((now + 7.days).to_i)
      end

      it 'deletes quarantined file' do
        path_to_file = './tmp/files/quarantine/7d/4d91e82727bdca3f0496f84e90d6ee94d81767b661683e1396aefffe4d55a2cd'
        expect(File.exist?(path_to_file)).to be_falsey
      end
    end
  end
end
