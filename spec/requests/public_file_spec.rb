require 'rails_helper'

RSpec.describe 'POST /service/:service_slug/user/:user_identifier/public-file', type: :request do
  let(:service_slug) { 'my-service' }
  let(:user_identifier) { SecureRandom::uuid }
  let(:headers) do
    { 'content-type' => 'application/json' }
  end
  let(:url) { "/service/#{service_slug}/user/#{user_identifier}/public-file" }
  let(:body) { { url: 'http://fb-user-filestore-api-svc-test-dev.formbuilder-platform-test-dev/service/ioj/user/a239313d-4d2d-4a16-b5ef-69d6e8e53e86/28d-aaa59621acecd4b1596dd0e96968c6cec3fae7927613a12c357e7a62e1187aaa' } }

  it 'responds with a 201 created' do
    post url, params: body.to_json, headers: headers
    expect(response.status).to eq(201)
  end
end
