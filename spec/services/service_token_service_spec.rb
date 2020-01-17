require 'rails_helper'

RSpec.describe ServiceTokenService do
  let(:service_slug) { 'service-slug' }
  let(:fake_client) { double('fake_client') }

  subject { described_class.new(service_slug: service_slug) }

  describe '#get' do
    it 'delegates call to client' do
      allow(Adapters::ServiceTokenCacheClient).to receive(:new).and_return(fake_client)
      expect(fake_client).to receive(:get).with(service_slug).and_return(service_slug)

      expect(subject.get).to eql(service_slug)
    end
  end
end
