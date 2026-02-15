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

  it "recomputes total copies when only available_copies is provided" do
    member = User.create!(email: "inventory_member_update@example.com", password: "password123", password_confirmation: "password123", role: "member")
    Borrowing.create!(user: member, book: book, borrowed_at: 2.days.ago, due_at: 12.days.from_now, returned_at: nil)

    result = described_class.call(book: book, params: { available_copies: 10 })

    expect(result).to be_success
    expect(result.book.reload.total_copies).to eq(11)
    expect(result.book.available_copies).to eq(10)
  end

  it "recomputes available copies when only total_copies is provided" do
    member = User.create!(email: "inventory_member_total@example.com", password: "password123", password_confirmation: "password123", role: "member")
    Borrowing.create!(user: member, book: book, borrowed_at: 2.days.ago, due_at: 12.days.from_now, returned_at: nil)

    result = described_class.call(book: book, params: { total_copies: 7 })

    expect(result).to be_success
    expect(result.book.reload.available_copies).to eq(6)
    expect(result.book.total_copies).to eq(7)
  end

  it "returns errors when total and available copies are inconsistent with active borrowings" do
    member = User.create!(email: "inventory_member_inconsistent@example.com", password: "password123", password_confirmation: "password123", role: "member")
    Borrowing.create!(user: member, book: book, borrowed_at: 2.days.ago, due_at: 12.days.from_now, returned_at: nil)

    result = described_class.call(book: book, params: { total_copies: 7, available_copies: 3 })

    expect(result).not_to be_success
    expect(result.errors).to include(:available_copies)
  end

  it "returns errors when total copies is lower than active borrowings" do
    member = User.create!(email: "inventory_member_low_total@example.com", password: "password123", password_confirmation: "password123", role: "member")
    Borrowing.create!(user: member, book: book, borrowed_at: 2.days.ago, due_at: 12.days.from_now, returned_at: nil)

    result = described_class.call(book: book, params: { total_copies: 0 })

    expect(result).not_to be_success
    expect(result.errors).to include(:total_copies)
  end
end
