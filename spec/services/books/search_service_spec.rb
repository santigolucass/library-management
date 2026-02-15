require "rails_helper"

RSpec.describe Books::SearchService do
  let!(:matching) do
    Book.create!(title: "Practical Object-Oriented Design", author: "Sandi Metz", genre: "Software", isbn: "9783000000003", total_copies: 1, available_copies: 1)
  end

  let!(:other) do
    Book.create!(title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", isbn: "9783000000004", total_copies: 1, available_copies: 1)
  end

  it "filters by title, author, or genre" do
    result = described_class.call(scope: Book.order(:id), query: "sandi")

    expect(result).to contain_exactly(matching)
  end

  it "returns original scope when query is blank" do
    result = described_class.call(scope: Book.order(:id), query: "")

    expect(result).to include(matching, other)
  end
end
