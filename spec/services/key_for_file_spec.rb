require 'rails_helper'

RSpec.describe KeyForFile do
  subject do
    described_class.new(service_slug: 'service-slug',
                        user_id: 'user-id',
                        file_fingerprint: 'file-fingerprint',
                        days_to_live: 28,
                        cipher_key: '12345678901234567890123456789012')
  end

  before :each do
    allow(ServiceTokenService).to receive(:get).with('service-slug')
                                               .and_return('service-token')
  end

  it 'returns correct key' do
    expect(subject.call).to eql('28d/2f3a5064d166075a9b67b09f2033b5a0445829d162ebc6348585aee48d3cfe1a')
  end
end
