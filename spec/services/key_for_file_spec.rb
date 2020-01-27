require 'rails_helper'

RSpec.describe KeyForFile do
  include KeyHelpers

  subject do
    described_class.new(service_slug: 'service-slug',
                        user_id: 'user-id',
                        file_fingerprint: 'file-fingerprint',
                        days_to_live: 28,
                        cipher_key: '12345678901234567890123456789012')
  end

  let(:fake_service) { double('service') }

  before :each do
    allow(ServiceTokenService).to receive(:new).with(service_slug: 'service-slug')
                                               .and_return(fake_service)
    allow(fake_service).to receive(:public_key).and_return(public_key)
  end

  it 'returns correct key' do
    expect(subject.call).to eql('28d/aa3c71a7af28362def09e52291ae8c147356b3ef7aa6d5d65032832c19421c56')
  end
end
