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

  it "returns unprocessable entity when return service fails" do
    borrowing = Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)
    result = instance_double(Borrowings::ReturnService::Result, success?: false, errors: { returned_at: ["is invalid"] })
    allow(Borrowings::ReturnService).to receive(:call).and_return(result)

    post "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(json_response).to eq("errors" => { "returned_at" => ["is invalid"] })
  end

  it "scopes borrowing list for members and allows librarians to view all" do
    own = Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)
    other = Borrowing.create!(user: another_member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)

    get "/api/v1/borrowings", headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to contain_exactly(own.id)
    borrowing_payload = json_response.fetch("data").first
    expect(borrowing_payload.dig("user", "email")).to eq(member.email)
    expect(borrowing_payload.dig("book", "title")).to eq(book.title)
    expect(borrowing_payload).not_to have_key("user_id")
    expect(borrowing_payload).not_to have_key("book_id")

    get "/api/v1/borrowings", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to include(own.id, other.id)
  end

  it "orders borrowings as active, overdue, then returned" do
    active_book = Book.create!(title: "Active Book", author: "A", genre: "G", isbn: "9780000000101", total_copies: 2, available_copies: 2)
    overdue_book = Book.create!(title: "Overdue Book", author: "B", genre: "G", isbn: "9780000000102", total_copies: 2, available_copies: 2)
    returned_book = Book.create!(title: "Returned Book", author: "C", genre: "G", isbn: "9780000000103", total_copies: 2, available_copies: 2)

    returned = Borrowing.create!(user: member, book: returned_book, borrowed_at: 7.days.ago, due_at: 3.days.ago, returned_at: 1.day.ago)
    overdue = Borrowing.create!(user: another_member, book: overdue_book, borrowed_at: 10.days.ago, due_at: 1.day.ago)
    active = Borrowing.create!(user: member, book: active_book, borrowed_at: 1.day.ago, due_at: 5.days.from_now)

    get "/api/v1/borrowings", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to eq([active.id, overdue.id, returned.id])
  end
end
