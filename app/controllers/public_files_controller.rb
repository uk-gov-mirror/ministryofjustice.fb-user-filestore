class PublicFilesController < ApplicationController
  before_action :check_params, only: [:create]

  def create
    render json: {}, status: 201
  end

  private

  def check_params
    if params[:url].blank?
      return render json: { code: 400, name: 'invalid.url-missing' }, status: 400
    end
  end
end
