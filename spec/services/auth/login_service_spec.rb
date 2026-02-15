require "rails_helper"

RSpec.describe Auth::LoginService do
  let!(:member) do
    User.create!(email: "login_service_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  it "returns user and token for valid credentials" do
    result = described_class.call(email: member.email, password: "password123")

    expect(result).to be_success
    expect(result.user).to eq(member)
    expect(result.token).to be_present
  end

  it "returns contract-compatible error for invalid credentials" do
    result = described_class.call(email: member.email, password: "wrong")

    expect(result).not_to be_success
    expect(result.error).to eq("Invalid email or password")
  end
end
