require "rails_helper"

RSpec.describe "CORS preflight", type: :request do
  it "handles OPTIONS for auth register endpoint" do
    options "/api/v1/auth/register", headers: {
      "Origin" => "http://localhost:5173",
      "Access-Control-Request-Method" => "POST",
      "Access-Control-Request-Headers" => "Content-Type"
    }

    expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:5173")
    expect(response.headers["Access-Control-Allow-Methods"]).to include("POST")
  end

  it "allows localhost preview port for auth login endpoint" do
    options "/api/v1/auth/login", headers: {
      "Origin" => "http://localhost:4173",
      "Access-Control-Request-Method" => "POST",
      "Access-Control-Request-Headers" => "Content-Type"
    }

    expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:4173")
    expect(response.headers["Access-Control-Allow-Methods"]).to include("POST")
  end
end
