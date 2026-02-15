require "rails_helper"

RSpec.describe "GET /dashboard/member", type: :request do
  let!(:member) do
    User.create!(email: "member_dashboard_data@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  let!(:other_member) do
    User.create!(email: "member_dashboard_other@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  let!(:book) do
    Book.create!(title: "Member Dashboard Book", author: "Author", genre: "Genre", isbn: "9783999999904", total_copies: 5, available_copies: 5)
  end
  let!(:second_book) do
    Book.create!(title: "Member Dashboard Book 2", author: "Author", genre: "Genre", isbn: "9783999999905", total_copies: 5, available_copies: 5)
  end

  it "returns active and overdue borrowing payloads for current member only" do
    active = Borrowing.create!(user: member, book: book, borrowed_at: 1.day.ago, due_at: 3.days.from_now, returned_at: nil)
    overdue = Borrowing.create!(user: member, book: second_book, borrowed_at: 10.days.ago, due_at: 1.day.ago, returned_at: nil)
    Borrowing.create!(user: other_member, book: book, borrowed_at: 10.days.ago, due_at: 2.days.ago, returned_at: nil)

    get "/api/v1/dashboard/member", headers: auth_headers_for(email: member.email, password: "password123"), as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response.fetch("active_borrowings").map { |b| b.fetch("id") }).to contain_exactly(active.id, overdue.id)
    expect(json_response.fetch("overdue_borrowings").map { |b| b.fetch("id") }).to contain_exactly(overdue.id)
    payload = json_response.fetch("active_borrowings").find { |item| item.fetch("id") == active.id }
    expect(payload.keys).to include("id", "user_id", "book_id", "borrowed_at", "due_at", "returned_at", "user", "book")
    expect(payload.dig("user", "email")).to eq(member.email)
    expect(payload.dig("book", "title")).to eq(book.title)
  end
end
