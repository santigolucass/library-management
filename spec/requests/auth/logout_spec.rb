require "rails_helper"

RSpec.describe "DELETE /auth/logout", type: :request do
  let!(:user) do
    User.create!(
      email: "logout_member@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "member"
    )
  end

  it "returns no content for valid bearer token" do
    post "/api/v1/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json

    token = JSON.parse(response.body).fetch("token")

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:no_content)
  end

  it "invalidates token after logout" do
    post "/api/v1/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json

    token = JSON.parse(response.body).fetch("token")

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{token}" }, as: :json
    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{token}" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end

  it "returns unauthorized error shape without bearer token" do
    delete "/api/v1/auth/logout", as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end

  it "returns unauthorized when JWT decode fails" do
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)
    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_raise(JWT::DecodeError)

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer invalid.token" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end

  it "returns unauthorized when token payload is missing required keys" do
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)
    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_return({})

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer malformed.payload" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end

  it "returns unauthorized when denylist persistence raises record invalid" do
    payload = { "jti" => "logout-jti-invalid", "sub" => user.id.to_s, "exp" => 1.hour.from_now.to_i }
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)
    invalid_record = JwtDenylist.new
    invalid_record.errors.add(:base, "invalid")

    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_return(payload)
    allow(JwtDenylist).to receive(:exists?).with(jti: payload["jti"]).and_return(false)
    allow(JwtDenylist).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(invalid_record))

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer valid.token" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end

  it "returns unauthorized when denylist persistence raises record not unique" do
    payload = { "jti" => "logout-jti-duplicate", "sub" => user.id.to_s, "exp" => 1.hour.from_now.to_i }
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)

    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_return(payload)
    allow(JwtDenylist).to receive(:exists?).with(jti: payload["jti"]).and_return(false)
    allow(JwtDenylist).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique.new("duplicate"))

    delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer valid.token" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end
end
