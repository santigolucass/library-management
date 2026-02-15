require "rails_helper"

RSpec.describe "Request spec baseline", type: :request do
  it "loads request helpers" do
    expect(self).to respond_to(:get)
  end
end
