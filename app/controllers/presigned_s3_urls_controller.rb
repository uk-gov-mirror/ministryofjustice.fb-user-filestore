class PresignedS3UrlsController < ApplicationController
  def create
    encryption_key = ssl.random_key
    encryption_iv = ssl.random_iv

    reencrypted_file_data = Cryptography.new(
      encryption_key: encryption_key,
      encryption_iv: encryption_iv
    ).encrypt(file: downloader.contents)

    uploader.upload(file_data: reencrypted_file_data)

    payload = {
      url: s3_url,
      encryption_key: Base64.strict_encode64(encryption_key),
      encryption_iv: Base64.strict_encode64(encryption_iv)
    }

    render json: payload.to_json, status: 201
  end

  private

  def s3_url
    signer = Aws::S3::Presigner.new
    signer.presigned_url(:get_object, bucket: public_bucket, key: key)
  end

  def ssl
    @ssl ||= OpenSSL::Cipher.new 'AES-256-CBC'
  end

  def downloader
    @downloader ||= Storage::S3::Downloader.new(key: key, bucket: bucket)
  end

  def uploader
    @uploader ||= Storage::S3::Uploader.new(key: key, bucket: public_bucket)
  end

  def key
    @key ||= KeyForFile.new(
      user_id: params[:user_id],
      service_slug: params[:service_slug],
      file_fingerprint: file_fingerprint,
      days_to_live: 1,
      cipher_key: cipher_key
    ).call
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET_NAME')
  end

  def public_bucket
    ENV.fetch('AWS_S3_EXTERNAL_BUCKET_NAME')
  end

  def file_fingerprint
    params[:fingerprint_with_prefix]
  end

  def cipher_key
    Digest::MD5.hexdigest(request.headers['x-encrypted-user-id-and-token'])
  end
end
