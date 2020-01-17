require 'rails_helper'

RSpec.describe Adapters::ServiceTokenCacheClient do
  describe 'initializing' do
    subject { described_class.new(params) }

    context 'with a :root_url param' do
      let(:params) { {root_url: 'a root url'} }

      it 'stores the root_url' do
        expect(subject.root_url).to eq('a root url')
      end
    end

    context 'with no :root_url param' do
      let(:params) { {} }
      it 'stores the environment variable SERVICE_TOKEN_CACHE_ROOT_URL as root_url' do
        allow(ENV).to receive(:[]).with('SERVICE_TOKEN_CACHE_ROOT_URL').and_return('value from env var')
        expect(subject.root_url).to eq('value from env var')
      end
    end
  end

  subject { described_class.new(root_url: 'http://www.example.com') }

  describe '#get' do
    let(:service_slug) { 'my-service' }
    let(:response_code) { '200' }
    let(:mock_response) { double('response', body: '{"token": "token value"}', code: response_code) }

    before do
      allow(subject).to receive(:service_token_uri).with(service_slug).and_return('http://service/token/url')
      allow(Net::HTTP).to receive(:get_response).and_return(mock_response)
    end

    it 'gets the service_token_uri for the given service_slug' do
      expect(subject).to receive(:service_token_uri).with(service_slug).and_return('http://service/token/url')
      subject.get(service_slug)
    end

    it 'makes a GET request to the service_token_uri' do
      expect(Net::HTTP).to receive(:get_response).with('http://service/token/url').and_return(mock_response)
      subject.get(service_slug)
    end

    context 'when the response has code 200' do
      let(:response_code) { '200' }

      it 'returns the token key from the body' do
        expect(subject.get(service_slug)).to eq('token value')
      end
    end

    context 'when the response code is not 200' do
      let(:response_code) { '418' }

      it 'returns nil' do
        expect(subject.get(service_slug)).to be_nil
      end
    end

    context 'when an error is raised' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'allows the error to pass out uncaught' do
        expect{subject.get(service_slug)}.to raise_error(JSON::ParserError)
      end
    end
  end

  describe '#public_key_for' do
    let(:service_slug) { 'my-service' }
    let(:encoded_public_key) do
      'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEzU1RCMkxnaDAyWWt0K0xxejluNgo5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlbHoxeHhwSk9MZXRyTGdxbjM3aE1qTlkwL25BQ2NNZHVFSDlLClhycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW5iZG0rNnM1S3ZMZ1VOTjdYVmNlUDlQdXFaeXN4Q1ZBNFRubUwKRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdFBiQWd4V0FmZVNMbGI3QlBsc0htL0gwQUFMK25iYU9Da3d2cgpQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05ac1RWUWFvNFh3aGVidWRobHZNaWtFVzMyV0tnS3VISFc4emR2ClU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0xBM1loOExJNUd5ZDlwNmYyN01mbGRnVUlIU3hjSnB5MUo4QVAKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=='
    end
    let(:mock_response) do
      double('response', body: {token: encoded_public_key}.to_json, code: 200)
    end

    it 'returns public key' do
      expect(Net::HTTP).to receive(:get_response).with(URI('http://www.example.com/service/v2/my-service')).and_return(mock_response)

      subject.public_key_for(service_slug)
    end
  end
end
