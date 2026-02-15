require "rails_helper"

RSpec.describe "POST /auth/register", type: :request do
  it "returns contract-compatible auth response" do
    post "/api/v1/auth/register", params: {
      email: "new_member@example.com",
      password: "password123",
      role: "member"
    }, as: :json

    expect(response).to have_http_status(:created)

    json = JSON.parse(response.body)
    expect(json.keys).to contain_exactly("user", "token")
    expect(json["token"]).to be_a(String)
    expect(response.headers["Authorization"]).to eq("Bearer #{json["token"]}")
    expect(json["user"]).to include(
      "email" => "new_member@example.com",
      "role" => "member"
    )
    expect(json["user"]["id"]).to be_a(Integer)
  end

  it "defaults role to member when role is omitted" do
    post "/api/v1/auth/register", params: {
      email: "default_role@example.com",
      password: "password123"
    }, as: :json

    expect(response).to have_http_status(:created)
    json = JSON.parse(response.body)
    expect(json.dig("user", "role")).to eq("member")
  end

  it "returns validation errors in contract shape" do
    post "/api/v1/auth/register", params: {
      email: "",
      password: "short"
    }, as: :json

    expect(response.status).to eq(422)
    json = JSON.parse(response.body)
    expect(json.keys).to eq(["errors"])
    expect(json["errors"]).to be_a(Hash)
  end
end
