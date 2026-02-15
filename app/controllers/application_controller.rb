class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def authenticate_api_user!
    token = request.authorization.to_s.split(" ", 2).last
    return render_unauthorized if token.blank?

    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    return render_unauthorized if JwtDenylist.exists?(jti: payload.fetch("jti"))

    @current_api_user = User.find_by(id: payload.fetch("sub"))
    return render_unauthorized unless @current_api_user
  rescue JWT::DecodeError, KeyError
    render_unauthorized
  end

  def current_api_user
    @current_api_user
  end

  def pundit_user
    current_api_user
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def render_not_found
    render json: { error: "Not found" }, status: :not_found
  end
end
