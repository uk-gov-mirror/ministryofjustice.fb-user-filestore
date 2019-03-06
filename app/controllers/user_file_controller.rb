class UserFileController < ApplicationController
  SERVICE_TOKEN = 'some-service-token'.freeze
  IV = '1234567890123451'.freeze

  def create
    @file_manager = FileManager.new(encoded_file: params[:file],
                                    user_id: params[:user_id],
                                    service_token: params[:service_slug], # TODO: get token
                                    options: {
                                      max_size: params[:policy][:max_size],
                                      allowed_types: params[:policy][:allowed_types]
                                    })

    @file_manager.save_to_disk

    if @file_manager.file_too_large?
      return error_large_file(@file_manager.file_size)
    end

    unless @file_manager.type_permitted?
      return error_unsupported_file_type(@file_manager.mime_type)
    end

    if @file_manager.file_already_exists?
      return head :no_content
    end

    # async?
    @file_manager.upload

    hash = {
      url: "/service/#{service_slug}/user/#{user_id}/#{@file_manager.file_fingerprint}",
      size: @file_manager.file_size,
      type: @file_manager.mime_type,
      date: Time.now.to_i
    }

    render json: hash, status: 201
  rescue
    return error_server_error
  ensure
    # delete from quarantine
  end

  def show
    headers['x-access-token'] = 'ENCRYPTED_USER_ID + TOKEN'
  end

  private

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

  def error_server_error
    render json: { code: 503,
                   name: 'unavailable.file-store-failed' }, status: 503
  end

  # TODO sanatize?
  def user_id
    params[:user_id]
  end

  # TODO sanatize?
  def service_slug
    params[:service_slug]
  end
end
