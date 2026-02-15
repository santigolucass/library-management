require "rails_helper"

RSpec.describe "Books authorization", type: :request do
  let!(:librarian) do
    User.create!(email: "librarian_books@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end
  let!(:member) do
    User.create!(email: "member_books@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end
  let!(:book) do
    Book.create!(
      title: "Domain-Driven Design",
      author: "Eric Evans",
      genre: "Software",
      isbn: "9780321125217",
      total_copies: 5,
      available_copies: 5
    )
  end

  it "allows both roles to list books" do
    get "/api/v1/books", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json
    expect(response).to have_http_status(:ok)

    get "/api/v1/books", headers: auth_headers_for(email: member.email, password: "password123"), as: :json
    expect(response).to have_http_status(:ok)
  end

  it "forbids members from creating books" do
    post "/api/v1/books", params: {
      title: "New Book",
      author: "Author",
      genre: "Genre",
      isbn: "9781111111111",
      total_copies: 2
    }, headers: auth_headers_for(email: member.email, password: "password123"), as: :json

    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end

  it "allows librarians to create books" do
    post "/api/v1/books", params: {
      title: "Librarian Book",
      author: "Author",
      genre: "Genre",
      isbn: "9782222222222",
      total_copies: 2
    }, headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    expect(response).to have_http_status(:created)
    expect(json_response.fetch("data").fetch("title")).to eq("Librarian Book")
  end

  it "forbids members from updating and deleting books" do
    patch "/api/v1/books/#{book.id}", params: {
      title: "Changed",
      author: book.author,
      genre: book.genre,
      isbn: book.isbn,
      total_copies: book.total_copies
    }, headers: auth_headers_for(email: member.email, password: "password123"), as: :json

    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")

    delete "/api/v1/books/#{book.id}", headers: auth_headers_for(email: member.email, password: "password123"), as: :json

    expect(response).to have_http_status(:forbidden)
    expect(json_response).to eq("error" => "Forbidden")
  end

  it "returns 409 when deleting a book that has active borrowings" do
    Borrowing.create!(user: member, book: book, borrowed_at: Time.current, due_at: 7.days.from_now)

    delete "/api/v1/books/#{book.id}", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    expect(response).to have_http_status(:conflict)
    expect(json_response).to include("error")
  end

  it "returns 204 when deleting a book that has only returned borrowings" do
    Borrowing.create!(
      user: member,
      book: book,
      borrowed_at: 10.days.ago,
      due_at: 5.days.ago,
      returned_at: 4.days.ago
    )

    delete "/api/v1/books/#{book.id}", headers: auth_headers_for(email: librarian.email, password: "password123"), as: :json

    expect(response).to have_http_status(:no_content)
  end
end
