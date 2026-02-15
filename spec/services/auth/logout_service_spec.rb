require "rails_helper"

RSpec.describe Auth::LogoutService do
  let!(:member) do
    User.create!(email: "logout_service_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  it "revokes a valid bearer token" do
    token = Warden::JWTAuth::UserEncoder.new.call(member, :user, nil).first

    result = described_class.call(authorization_header: "Bearer #{token}")

    expect(result).to be_success
    expect(JwtDenylist.count).to eq(1)
  end

  it "returns unauthorized for blank header" do
    result = described_class.call(authorization_header: nil)

    expect(result).not_to be_success
    expect(result.error).to eq("Unauthorized")
  end
end
