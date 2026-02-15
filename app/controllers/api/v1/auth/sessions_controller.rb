module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        def create
          user = User.find_for_database_authentication(email: params[:email].to_s.strip.downcase)

          if user&.valid_password?(params[:password].to_s)
            sign_in(:user, user, store: false)
            token = jwt_token_for(user)
            response.set_header("Authorization", "Bearer #{token}")
            render json: { user: AuthUserPresenter.new(user).as_json, token: token }, status: :ok
          else
            render json: { error: "Invalid email or password" }, status: :unauthorized
          end
        end

        def destroy
          token = bearer_token
          return render json: { error: "Unauthorized" }, status: :unauthorized if token.blank?

          payload = Warden::JWTAuth::TokenDecoder.new.call(token)
          return render json: { error: "Unauthorized" }, status: :unauthorized if JwtDenylist.exists?(jti: payload.fetch("jti"))

          user = User.find_by(id: payload.fetch("sub"))
          return render json: { error: "Unauthorized" }, status: :unauthorized unless user

          JwtDenylist.create!(jti: payload.fetch("jti"), exp: Time.at(payload.fetch("exp").to_i))
          head :no_content
        rescue JWT::DecodeError, KeyError, ActiveRecord::RecordInvalid
          render json: { error: "Unauthorized" }, status: :unauthorized
        rescue ActiveRecord::RecordNotUnique
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        private

        def jwt_token_for(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        end

        def bearer_token
          request.authorization.to_s.split(" ", 2).last
        end
      end
    end
  end
end
