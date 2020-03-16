require 'rails_helper'

RSpec.describe ApplicationController do
  context 'when there is an error' do
    controller do
      include Concerns::ErrorHandling

      def index
        raise :foo
      end
    end

    it 'calls raven (sentry) with exception' do
      expect(Raven).to receive(:capture_exception)
      get :index, format: :json
    end
  end

  context 'when there is no error' do
    controller do
      include Concerns::ErrorHandling

      def index
      end
    end

    it 'does not call raven (sentry)' do
      expect(Raven).to_not receive(:capture_exception)
      get :index, format: :json
    end
  end
end
