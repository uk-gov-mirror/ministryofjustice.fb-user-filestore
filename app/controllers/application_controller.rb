class ApplicationController < ActionController::API
  include Concerns::ErrorHandling

  before_action :enforce_json_only

  private

  def enforce_json_only
    response.status = :unacceptable unless request.format.json?
  end
end
