require 'rails_helper'

describe 'file download', type: :request do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:verify_token!)
  end

  describe 'GET /service/{service_slug}/{user_id}/{fingerprint} request' do
    let(:do_get!) do
      get '/service/service-slug/user/user-id/fingerprint'
    end

    context 'when file does exist' do
      around :each do |example|
        FileUtils.cp(file_fixture('hello_world.txt'), Rails.root.join('tmp/files/28d/3bba5a1694c27d3d3749a2ed96b0dd289bc56c37d145a8fee476f695c98db260'))
        example.run
        FileUtils.rm(Rails.root.join('tmp/files/28d/3bba5a1694c27d3d3749a2ed96b0dd289bc56c37d145a8fee476f695c98db260'))
      end

      it 'returns status 200' do
        do_get!
        expect(response).to be_successful
      end

      it 'returns correct json' do
        do_get!
        hash = JSON.parse(response.body)
        expect(hash['file']).to eql(Base64.encode64('Hello World'))
      end

      it 'removes the temporary file' do
        do_get!
        downloader = controller.send(:downloader)
        expect(File.exist?(downloader.file.path)).to be_falsey
      end
    end

    context 'when file does not exist' do
      it 'returns status 404' do
        do_get!
        expect(response).to be_not_found
      end

      it 'returns correct json' do
        do_get!
        hash = JSON.parse(response.body)
        expect(hash['code']).to eql(404)
        expect(hash['name']).to eql('not-found')
      end
    end

    context 'when there is a problem' do
      it 'returns 503' do
        downloader = double('downloader', exists?: true, encoded_contents: '')
        allow(Storage::Disk::Downloader).to receive(:new).and_return(downloader)
        allow(downloader).to receive(:encoded_contents).and_raise(StandardError.new)

        do_get!

        expect(response.status).to eql(503)
      end
    end
  end
end
