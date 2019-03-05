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

    # filename = generate_filename(@file_manager.file, params[:user_id], SERVICE_TOKEN)
    # encrypted_filename = encrypt_filename(params[:encrypted_user_id_and_token], @file_manager.random_filename, IV)
    # hashed_filename = hashed_digest(encrypted_filename)

    @file_manager.upload
    # delete from quarantine

    render json: { }, status: 200
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

  def generate_filename(file, user_id, service_token)
    checksum = Digest::SHA1.file(file).to_s
    Digest::SHA1.hexdigest(service_token + user_id + checksum)
  end

  def encrypt_filename(key, filename, iv)
    cipher = OpenSSL::Cipher.new 'AES-256-CBC'
    cipher.encrypt
    cipher.iv = iv
    cipher.key = key
    encrypted = cipher.update(filename) + cipher.final
    encrypted.unpack1('H*')
  end

  def hashed_digest(filename)
    Digest::SHA1.hexdigest(filename)
  end

  def full_filename(service_slug, user_id, filename)
    "#{service_slug}/#{user_id}/#{filename}"
  end
end
