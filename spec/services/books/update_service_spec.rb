require "rails_helper"

RSpec.describe Books::UpdateService do
  let!(:book) do
    Book.create!(
      title: "Old Title",
      author: "Author",
      genre: "Genre",
      isbn: "9783999999901",
      total_copies: 2,
      available_copies: 2
    )
  end

  it "updates a book successfully" do
    result = described_class.call(book: book, params: { title: "New Title" })

    expect(result).to be_success
    expect(result.book.reload.title).to eq("New Title")
  end

  it "returns validation errors when update fails" do
    result = described_class.call(book: book, params: { title: "" })

    expect(result).not_to be_success
    expect(result.errors).to include(:title)
  end
end
