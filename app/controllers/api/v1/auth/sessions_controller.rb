module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        def create
          result = ::Auth::LoginService.call(email: params[:email], password: params[:password])

          if result.success?
            sign_in(:user, result.user, store: false)
            response.set_header("Authorization", "Bearer #{result.token}")
            render json: { user: AuthUserPresenter.new(result.user).as_json, token: result.token }, status: :ok
          else
            render json: { error: result.error }, status: :unauthorized
          end
        end

        def destroy
          result = ::Auth::LogoutService.call(authorization_header: request.authorization)
          return head :no_content if result.success?

          render json: { error: result.error }, status: :unauthorized
        end
      end
    end
  end
end
