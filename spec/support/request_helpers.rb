module Requests
  module JsonHelpers
    def json
      JSON.parse(body.to_s)
    end
  end
end


def json_request(encoded_file, options = {})
  expires = options[:expires] || 28
  allowed_types = options[:allowed_types] || %w[
    text/plain
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/msword
    application/vnd.oasis.opendocument.text
    application/pdf
    image/jpeg
    image/png
    application/vnd.ms-excel
  ]

  {
    "iat": '{timestamp}',
    "encrypted_user_id_and_token": '12345678901234567890123456789012',
    "file": encoded_file,
    "policy": {
      "allowed_types": allowed_types,
        "max_size": '10240',
        "expires": expires
    }
  }
end
