require "rails_helper"

RSpec.describe Dashboards::LibrarianSummaryQuery do
  let!(:librarian) do
    User.create!(email: "dashboard_service_librarian@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:member) do
    User.create!(email: "dashboard_service_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:book) do
    Book.create!(title: "Dash Service", author: "Author", genre: "Genre", isbn: "9783000000005", total_copies: 2, available_copies: 2)
  end

  it "returns contract fields" do
    Borrowing.create!(user: member, book: book, borrowed_at: 10.days.ago, due_at: 1.day.ago, returned_at: nil)

    result = described_class.call(now: Time.current)

    expect(result).to include(:total_books, :total_borrowed_books, :books_due_today, :overdue_members)
    expect(result[:overdue_members]).to include(hash_including(user_id: member.id, email: member.email, overdue_count: 1))
  end
end
