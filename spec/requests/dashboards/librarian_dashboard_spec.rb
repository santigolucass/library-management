require "rails_helper"

RSpec.describe "GET /dashboard/librarian", type: :request do
  let!(:librarian) do
    User.create!(email: "dashboard_librarian@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:member_one) do
    User.create!(email: "overdue_one@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:member_two) do
    User.create!(email: "overdue_two@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:book_a) do
    Book.create!(title: "Book A", author: "Author A", genre: "Genre", isbn: "9780000000001", total_copies: 3, available_copies: 3)
  end
  let!(:book_b) do
    Book.create!(title: "Book B", author: "Author B", genre: "Genre", isbn: "9780000000002", total_copies: 3, available_copies: 3)
  end

  it "returns aggregate metrics and overdue member list" do
    baseline_books = Book.count
    baseline_active_borrowings = Borrowing.active.count

    Borrowing.create!(user: member_one, book: book_a, borrowed_at: 10.days.ago, due_at: 1.day.ago, returned_at: nil)
    Borrowing.create!(user: member_one, book: book_b, borrowed_at: 12.days.ago, due_at: 2.days.ago, returned_at: nil)
    Borrowing.create!(user: member_two, book: book_b, borrowed_at: 2.days.ago, due_at: 5.days.from_now, returned_at: nil)
    Borrowing.create!(user: member_two, book: book_a, borrowed_at: 14.days.ago, due_at: 7.days.ago, returned_at: Time.current)

    get "/api/v1/dashboard/librarian", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response.fetch("total_books")).to eq(baseline_books)
    expect(json_response.fetch("total_borrowed_books")).to eq(baseline_active_borrowings + 3)

    overdue_members = json_response.fetch("overdue_members")
    expect(overdue_members).to include(
      hash_including(
        "user_id" => member_one.id,
        "email" => member_one.email,
        "overdue_count" => 2
      )
    )
  end
end
