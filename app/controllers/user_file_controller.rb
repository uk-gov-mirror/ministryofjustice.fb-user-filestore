class UserFileController < ApplicationController
  def create
    result = File.open('files/result', 'wb')
    result.write(Base64.decode64(params[:file]))
    result.close

    file_size = File.size('files/result')
    return error_large_file(file_size) if file_size > params[:policy][:max_size].to_i

    mime_type = `file --b --mime-type 'files/result'`.strip
    return error_unsupported_file_type(mime_type) unless params[:policy][:allowed_types].include?(mime_type)

    render json: { name: 'success' }, status: 200
  end

  def error_large_file(size)
    render json: { code: 400,
                   name: 'invalid.too-large',
                   max_size: params[:policy][:max_size],
                   size: size }, status: 400
  end

  def error_unsupported_file_type(type)
    render json: { code: 400,
                   name: 'invalid type',
                   type: type }, status: 400
  end
end
