require 'rails_helper'

RSpec.describe ServiceTokenService do
  describe '::get' do
    let(:fake_client) { double('fake_client') }

    it 'delegate call to client' do
      allow(ServiceTokenService).to receive(:client).and_return(fake_client)
      expect(fake_client).to receive(:get).with('service-slug')
      described_class.get('service-slug')
    end
  end

  describe '::client' do
    it 'returns a ServiceTokenCacheClient' do
      expect(described_class.client).to be_a(Adapters::ServiceTokenCacheClient)
    end
  end
end
