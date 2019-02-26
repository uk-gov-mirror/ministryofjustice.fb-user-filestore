class UserFileController < ApplicationController
  def create
    result = File.open("files/result", "w")
    result.print(Base64.decode64(params[:file]))
    result.close
    head :ok
  end
end
