module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        def create
          user = User.new(sign_up_params)
          user.role = requested_role

          if user.save
            sign_in(:user, user, store: false)
            render_auth_response(user, :created)
          else
            render json: { errors: user.errors.to_hash(true) }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.permit(:email, :password)
        end

        def requested_role
          role = params[:role]
          return "member" if role.blank?

          role.to_s
        end

        def render_auth_response(user, status)
          token = jwt_token_for(user)
          response.set_header("Authorization", "Bearer #{token}")
          render json: { user: AuthUserPresenter.new(user).as_json, token: token }, status: status
        end

        def jwt_token_for(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        end
      end
    end
  end
end
