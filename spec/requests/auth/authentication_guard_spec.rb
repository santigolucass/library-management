require "rails_helper"

RSpec.describe "Application authentication guard", type: :request do
  it "returns unauthorized when JWT decode fails in protected endpoint" do
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)
    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_raise(JWT::DecodeError)

    get "/api/v1/books", headers: { "Authorization" => "Bearer bad.token" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
  end

  it "returns unauthorized when JWT payload misses required keys" do
    decoder = instance_double(Warden::JWTAuth::TokenDecoder)
    allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
    allow(decoder).to receive(:call).and_return({ "sub" => "1" })

    get "/api/v1/books", headers: { "Authorization" => "Bearer missing.jti" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
  end
end
