require "rails_helper"

RSpec.describe Books::CreateService do
  it "returns validation errors when create fails" do
    result = described_class.call(params: { title: "", author: "", genre: "", isbn: "", total_copies: 1 })

    expect(result).not_to be_success
    expect(result.errors).to include(:title, :author, :genre, :isbn)
  end
end
