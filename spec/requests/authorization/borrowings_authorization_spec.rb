require "rails_helper"

RSpec.describe "Borrowings authorization", type: :request do
  let!(:librarian) do
    User.create!(email: "librarian_borrow@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:member) do
    User.create!(email: "member_borrow@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:another_member) do
    User.create!(email: "member_two_borrow@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:book) do
    Book.create!(
      title: "Refactoring",
      author: "Martin Fowler",
      genre: "Software",
      isbn: "9780201485677",
      total_copies: 5,
      available_copies: 5
    )
  end

  it "allows members to borrow and forbids librarians" do
    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    expect(response).to have_http_status(:created)

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end

  it "allows librarians to return and forbids members" do
    borrowing = Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)

    post "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    expect(response).to have_http_status(:ok)

    borrowing.update!(returned_at: nil)
    post "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(email: member.email, password: "password123"), as: :json

    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end

  it "scopes borrowing list for members and allows librarians to view all" do
    own = Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)
    other = Borrowing.create!(user: another_member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)

    get "/api/v1/borrowings", headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to contain_exactly(own.id)

    get "/api/v1/borrowings", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to include(own.id, other.id)
  end
end
