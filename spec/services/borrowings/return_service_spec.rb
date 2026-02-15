require "rails_helper"

RSpec.describe Borrowings::ReturnService do
  let!(:member) do
    User.create!(email: "return_service_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  let!(:book) do
    Book.create!(title: "Return Service", author: "Author", genre: "Service", isbn: "9783000000002", total_copies: 2, available_copies: 1)
  end

  let!(:borrowing) do
    Borrowing.create!(user: member, book: book, borrowed_at: Time.current - 1.day, due_at: Time.current + 13.days, returned_at: nil)
  end

  it "marks borrowing as returned" do
    now = Time.current

    result = described_class.call(borrowing: borrowing, now: now)

    expect(result).to be_success
    expect(result.borrowing.reload.returned_at.to_i).to eq(now.to_i)
  end
end
