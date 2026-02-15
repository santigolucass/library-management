require "rails_helper"

RSpec.describe "Test baseline" do
  it "boots the Rails test environment" do
    expect(Rails.env).to eq("test")
  end
end
