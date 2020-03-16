class ApplicationController < ActionController::API
  include Concerns::ErrorHandling

  before_action :enforce_json_only

  private

  def enforce_json_only
    unless request.format.json? # rubocop:disable Style/GuardClause
      render json: { error: 'Format not acceptable' }, status: :not_acceptable
    end
  end
end
