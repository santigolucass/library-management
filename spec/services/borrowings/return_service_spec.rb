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

  it "returns validation errors when update fails" do
    fake_borrowing = instance_double(Borrowing)
    fake_errors = instance_double(ActiveModel::Errors)

    allow(fake_borrowing).to receive(:update).with(returned_at: kind_of(Time)).and_return(false)
    allow(fake_borrowing).to receive(:errors).and_return(fake_errors)
    allow(fake_errors).to receive(:to_hash).with(true).and_return({ returned_at: [ "is invalid" ] })

    result = described_class.call(borrowing: fake_borrowing, now: Time.current)

    expect(result).not_to be_success
    expect(result.errors).to eq({ returned_at: [ "is invalid" ] })
  end
end
