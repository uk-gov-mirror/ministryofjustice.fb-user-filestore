class UserFileController < ApplicationController
  def create

    render plain: Base64.decode64(params[:file])
  end
end
