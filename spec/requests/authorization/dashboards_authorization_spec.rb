require "rails_helper"

RSpec.describe "Dashboard authorization", type: :request do
  let!(:librarian) do
    User.create!(email: "librarian_dashboard@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:member) do
    User.create!(email: "member_dashboard@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  it "allows librarian dashboard only for librarians" do
    get "/api/v1/dashboard/librarian", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    expect(response).to have_http_status(:ok)

    get "/api/v1/dashboard/librarian", headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end

  it "allows member dashboard only for members" do
    get "/api/v1/dashboard/member", headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    expect(response).to have_http_status(:ok)

    get "/api/v1/dashboard/member", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end
end
