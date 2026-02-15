module Auth
  class TokenIssuer
    def self.call(user)
      Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    end
  end
end
