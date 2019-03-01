require 'rails_helper'

describe Adapters::ServiceTokenCacheClient do
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

  describe '#service_token_uri' do
    subject { described_class.new(root_url: 'http://my.root.url/') }

    it 'returns a URI' do
      expect(subject.service_token_uri('my-service')).to be_a(URI)
    end

    it 'is the @root_url followed by /service/(service_slug)' do
      expect(subject.service_token_uri('my-service').to_s).to eq('http://my.root.url/service/my-service')
    end
  end
end
