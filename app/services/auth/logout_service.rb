module Auth
  class LogoutService
    UNAUTHORIZED_ERROR = "Unauthorized".freeze

    Result = Struct.new(:error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    def self.call(authorization_header:)
      new(authorization_header: authorization_header).call
    end

    def initialize(authorization_header:)
      @authorization_header = authorization_header
    end

    def call
      token = authorization_header.to_s.split(" ", 2).last
      return unauthorized if token.blank?

      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      return unauthorized if JwtDenylist.exists?(jti: payload.fetch("jti"))

      user = User.find_by(id: payload.fetch("sub"))
      return unauthorized unless user

      JwtDenylist.create!(jti: payload.fetch("jti"), exp: Time.at(payload.fetch("exp").to_i))

      Result.new
    rescue JWT::DecodeError, KeyError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      unauthorized
    end

    private

    attr_reader :authorization_header

    def unauthorized
      Result.new(error: UNAUTHORIZED_ERROR)
    end
  end
end
