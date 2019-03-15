class DownloadsController < ApplicationController
  before_action :check_download_params, only: [:show]

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

  def check_download_params
    if params[:payload].blank?
      return render json: { code: 400, name: 'invalid.payload-missing' }, status: 400
    end

    params.merge!(JSON.parse(Base64.strict_decode64(params[:payload])).select{|k,_| %w{ encrypted_user_id_and_token }.include?(k)})

    if params[:encrypted_user_id_and_token].blank?
      return render json: { code: 400, name: 'invalid.payload-encrypted-user-id-and-token-missing' }, status: 400
    end
  end

  def downloader
    @downloader ||= Rails.configuration.x.storage_adapter.constantize::Downloader.new(key: key)
  end

  def file_fingerprint
    params[:fingerprint_with_prefix].split('-').last
  end

  def days_to_live
    params[:fingerprint_with_prefix].split('-').first.scan(/\d/).join.to_i
  end

  def key
    @key ||= KeyForFile.new(user_id: params[:user_id],
                            service_slug: params[:service_slug],
                            file_fingerprint: file_fingerprint,
                            days_to_live: days_to_live,
                            cipher_key: Digest::MD5.hexdigest(params[:encrypted_user_id_and_token])).call
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
end
