require "rails_helper"

RSpec.describe "POST /auth/login", type: :request do
  let!(:user) do
    User.create!(
      email: "login_member@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "member"
    )
  end

  it "returns contract-compatible auth response" do
    post "/api/v1/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json.keys).to contain_exactly("user", "token")
    expect(json["token"]).to be_a(String)
    expect(response.headers["Authorization"]).to eq("Bearer #{json["token"]}")
    expect(json.dig("user", "id")).to eq(user.id)
    expect(json.dig("user", "email")).to eq(user.email)
    expect(json.dig("user", "role")).to eq(user.role)
  end

  it "returns unauthorized error shape for invalid credentials" do
    post "/api/v1/auth/login", params: {
      email: user.email,
      password: "wrong-password"
    }, as: :json

    expect(response).to have_http_status(:unauthorized)
    json = JSON.parse(response.body)
    expect(json).to include("error")
  end
end
