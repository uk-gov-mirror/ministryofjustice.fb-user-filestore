module Concerns
  module JWTAuthentication
    extend ActiveSupport::Concern

    class SubjectMismatchError < StandardError; end

    included do
      before_action :verify_token!

      if ancestors.include?(Concerns::ErrorHandling)
        rescue_from Exceptions::TokenNotPresentError do |e|
          render_json_error :unauthorized, :token_not_present
        end
        rescue_from Exceptions::TokenNotValidError do |e|
          render_json_error :forbidden, :token_not_valid
        end
      end
    end

    private

    def verify_token!
      unless request.headers['x-access-token-v2']
        raise Exceptions::TokenNotPresentError
      end

      verify
    end

    def verify
      token = request.headers['x-access-token-v2']

      begin
        hmac_secret = public_key(params[:service_slug])
        @jwt_payload, _header = JWT.decode(
          token,
          hmac_secret,
          true,
          {
            exp_leeway: leeway,
            algorithm: 'RS256'
          }
        )

        Rails.logger.debug("  JWT payload: #{@jwt_payload}")

        # NOTE: verify_iat used to be in the JWT gem, but was removed in v2.2
        # so we have to do it manually
        iat_skew = @jwt_payload['iat'].to_i - Time.current.to_i
        if iat_skew.abs > leeway.to_i
          Rails.logger.debug("iat skew is #{iat_skew}, max is #{leeway} - INVALID")
          raise Exceptions::TokenNotValidError.new
        end

        Rails.logger.debug "token is valid"
      rescue StandardError => e
        Rails.logger.debug("Couldn't parse that token - error #{e}")
        raise Exceptions::TokenNotValidError.new
      end
    end

    def service_token(service_slug)
      service = ServiceTokenService.new(service_slug: service_slug)
      service.get
    end

    def public_key(service_slug)
      service = ServiceTokenService.new(service_slug: service_slug)
      service.public_key
    end

    def leeway
      @leeway ||= begin
        if request.headers['x-jwt-skew-override'].blank?
          ENV['MAX_IAT_SKEW_SECONDS']
        else
          request.headers['x-jwt-skew-override']
        end
      end
    end
  end
end
