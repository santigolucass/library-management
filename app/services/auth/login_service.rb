module Auth
  class LoginService
    Result = Struct.new(:user, :token, :error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    def self.call(email:, password:)
      new(email: email, password: password).call
    end

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_for_database_authentication(email: email.to_s.strip.downcase)

      unless user&.valid_password?(password.to_s)
        return Result.new(error: "Invalid email or password")
      end

      Result.new(user: user, token: Auth::TokenIssuer.call(user))
    end

    private

    attr_reader :email, :password
  end
end
