require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  it "stores revoked token identifiers with expiration" do
    denylist = described_class.create!(jti: "jti-123", exp: 1.day.from_now)

    expect(denylist).to be_persisted
    expect(denylist.jti).to eq("jti-123")
    expect(denylist.exp).to be_present
  end
end
