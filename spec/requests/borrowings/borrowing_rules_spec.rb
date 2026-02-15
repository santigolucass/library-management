require "rails_helper"

RSpec.describe "Borrowing rules", type: :request do
  let!(:member) do
    User.create!(email: "rules_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:librarian) do
    User.create!(email: "rules_librarian@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:book) do
    Book.create!(title: "Design Patterns", author: "GoF", genre: "Software", isbn: "9780201633610", total_copies: 1, available_copies: 1)
  end

  it "returns 409 when a member tries to borrow the same book twice while active" do
    headers = auth_headers_for(email: member.email, password: "password123")

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: headers, as: :json
    expect(response).to have_http_status(:created)

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: headers, as: :json

    expect(response).to have_http_status(:conflict)
    expect(json_response).to include("error")
  end

  it "returns 409 when a book has no available copies" do
    headers = auth_headers_for(email: member.email, password: "password123")
    other_member = User.create!(email: "rules_member_two@example.com", password: "password123", password_confirmation: "password123", role: "member")
    other_headers = auth_headers_for(email: other_member.email, password: "password123")

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: headers, as: :json
    expect(response).to have_http_status(:created)

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: other_headers, as: :json

    expect(response).to have_http_status(:conflict)
    expect(json_response).to include("error")
  end

  it "decrements available copies on borrow and restores on return" do
    member_headers = auth_headers_for(email: member.email, password: "password123")
    librarian_headers = auth_headers_for(email: librarian.email, password: "password123")

    post "/api/v1/borrowings/borrow", params: { book_id: book.id }, headers: member_headers, as: :json
    borrowing_payload = json_response.fetch("data")
    borrowing_id = json_response.fetch("data").fetch("id")
    expect(borrowing_payload.dig("user", "email")).to eq(member.email)
    expect(borrowing_payload.dig("book", "title")).to eq(book.title)
    expect(book.reload.available_copies).to eq(0)

    post "/api/v1/borrowings/#{borrowing_id}/return", headers: librarian_headers, as: :json

    expect(response).to have_http_status(:ok)
    returned_payload = json_response.fetch("data")
    expect(returned_payload.dig("user", "email")).to eq(member.email)
    expect(returned_payload.dig("book", "title")).to eq(book.title)
    expect(book.reload.available_copies).to eq(1)
  end
end
