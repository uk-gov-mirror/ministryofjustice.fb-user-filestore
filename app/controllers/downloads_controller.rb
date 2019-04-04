class DownloadsController < ApplicationController
  before_action :check_download_params

  def show
    if downloader.exists?
      send_data downloader.contents, status: 200
      downloader.purge_from_destination!
    else
      render json: { code: 404, name: 'not-found' }, status: 404
    end
  rescue StandardError
    return error_download_server_error
  end

  private

  def check_download_params
    if request.headers['x-encrypted-user-id-and-token'].blank?
      return render json: { code: 400, name: 'invalid.header-encrypted-user-id-and-token-missing' }, status: 400
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
                            cipher_key: Digest::MD5.hexdigest(request.headers['x-encrypted-user-id-and-token'])).call
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

  def error_download_server_error
    render json: { code: 503,
                   name: 'unavailable.file-retrieval-failed' }, status: 503
  end
end
