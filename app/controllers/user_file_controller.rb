class UserFileController < ApplicationController
  def create
    result = File.open('files/result', 'wb')
    result.write(Base64.decode64(params[:file]))
    result.close

    file_size = File.size('files/result')
    return head 400 if file_size > params[:policy][:max_size].to_i

    mime_type = `file --b --mime-type 'files/result'`.strip
    return head 400 unless params[:policy][:allowed_types].include?(mime_type)

    head 200
  end
end
