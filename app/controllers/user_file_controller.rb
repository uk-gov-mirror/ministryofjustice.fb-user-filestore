class UserFileController < ApplicationController
  def create
    result = File.open('files/result', 'w')
    result.print(Base64.decode64(params[:file]))
    result.close
    file_size = File.size('files/result')

    return head 400 if file_size > params[:policy][:max_size].to_i

    head 200
  end
end
