require "rails_helper"

RSpec.describe Borrowings::CreateService do
  let!(:member) do
    User.create!(email: "service_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  let!(:book) do
    Book.create!(title: "Service Book", author: "Service Author", genre: "Service", isbn: "9783000000001", total_copies: 2, available_copies: 2)
  end

  it "creates a borrowing with hard-coded 14 day due date" do
    now = Time.zone.parse("2026-02-15 10:00:00")

    result = described_class.call(user: member, book_id: book.id, now: now)

    expect(result).to be_success
    expect(result.borrowing.borrowed_at).to eq(now)
    expect(result.borrowing.due_at).to eq(now + 14.days)
  end

  it "returns conflict error when borrowing is invalid" do
    Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 14.days.from_now, returned_at: nil)
    book.update!(available_copies: 0)

    result = described_class.call(user: member, book_id: book.id, now: Time.current)

    expect(result).not_to be_success
    expect(result.error).to be_present
  end

  it "returns conflict instead of raising when persistence hits race constraints" do
    allow_any_instance_of(Borrowing).to receive(:save).and_raise(ActiveRecord::RecordNotUnique.new("duplicate key value"))

    expect do
      result = described_class.call(user: member, book_id: book.id, now: Time.current)
      expect(result).not_to be_success
      expect(result.error).to be_present
    end.not_to raise_error
  end
end
