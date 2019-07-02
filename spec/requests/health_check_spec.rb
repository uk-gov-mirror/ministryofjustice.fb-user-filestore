require 'rails_helper'

RSpec.describe 'health', type: :request do
  describe 'GET /health' do
    it 'responds with healthy' do
      get '/health'
      expect(response.status).to eq(200)
      expect(response.body).to eq('healthy')
    end
  end
end
