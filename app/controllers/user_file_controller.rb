class UserFileController < ApplicationController
  def create
    @file_manager = FileManager.new(encoded_file: params[:file],
                                    user_id: params[:user_id],
                                    service_slug: params[:service_slug],
                                    options: {
                                      max_size: params[:policy][:max_size],
                                      allowed_types: params[:policy][:allowed_types],
                                      days_to_live: params[:policy][:expires]
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
      url: "/service/#{service_slug}/user/#{user_id}/#{@file_manager.fingerprint_with_prefix}",
      size: @file_manager.file_size,
      type: @file_manager.mime_type,
      date: Time.now.to_i
    }

    render json: hash, status: 201
  rescue
    return error_upload_server_error
  ensure
    @file_manager.delete_file if @file_manager
  end

  def show
    if downloader.exists?
      render json: { file: downloader.encoded_contents }, status: 200
      downloader.purge_from_destination!
    else
      render json: { code: 404, name: 'not-found' }, status: 404
    end
  rescue StandardError
    return error_download_server_error
  end

  private

  def downloader
    @downloader ||= Storage::Disk::Downloader.new(key: key)
  end

  def fingerprint
    params[:fingerprint_with_prefix].split('-').last
  end

  def days_to_live
    params[:fingerprint_with_prefix].split('-').first.scan(/\d/).join.to_i
  end

  def key
    @key ||= KeyForFile.new(user_id: params[:user_id],
                            service_slug: params[:service_slug],
                            file_fingerprint: fingerprint,
                            days_to_live: days_to_live).call
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

  def error_upload_server_error
    render json: { code: 503,
                   name: 'unavailable.file-store-failed' }, status: 503
  end

  def error_download_server_error
    render json: { code: 503,
                   name: 'unavailable.file-retrieval-failed' }, status: 503
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
