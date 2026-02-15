require "rails_helper"

RSpec.describe "Books lifecycle", type: :request do
  let!(:librarian) do
    User.create!(email: "book_lifecycle_librarian@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
  end

  let!(:book) do
    Book.create!(
      title: "Lifecycle Book",
      author: "Author",
      genre: "Genre",
      isbn: "9783999999903",
      total_copies: 4,
      available_copies: 4
    )
  end

  let(:headers) { auth_headers_for(email: librarian.email, password: "password123") }

  it "shows a book" do
    get "/api/v1/books/#{book.id}", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response.fetch("data").fetch("id")).to eq(book.id)
  end

  it "returns not found for unknown book id" do
    get "/api/v1/books/999999", headers: headers, as: :json

    expect(response).to have_http_status(:not_found)
    expect(json_response).to eq("error" => "Not found")
  end

  it "updates a book" do
    patch "/api/v1/books/#{book.id}",
          params: { title: "Updated Title", author: book.author, genre: book.genre, isbn: book.isbn, total_copies: book.total_copies },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response.fetch("data").fetch("title")).to eq("Updated Title")
  end

  it "returns validation errors on invalid update" do
    patch "/api/v1/books/#{book.id}",
          params: { title: "", author: book.author, genre: book.genre, isbn: book.isbn, total_copies: book.total_copies },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(json_response.fetch("errors")).to include("title")
  end

  it "returns validation errors when required update fields are missing" do
    patch "/api/v1/books/#{book.id}",
          params: { title: "Updated Only Title" },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(json_response.fetch("errors")).to include("author", "genre", "isbn", "total_copies")
  end

  it "returns validation errors on invalid create" do
    post "/api/v1/books",
         params: { title: "", author: "", genre: "", isbn: "", total_copies: 1 },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(json_response.fetch("errors")).to include("title")
  end

  it "deletes a book" do
    delete "/api/v1/books/#{book.id}", headers: headers, as: :json

    expect(response).to have_http_status(:no_content)
    expect(Book.exists?(book.id)).to be(false)
  end

  it "returns conflict when delete restriction is raised during destroy" do
    allow_any_instance_of(Book).to receive(:destroy!).and_raise(ActiveRecord::DeleteRestrictionError.new("Book"))

    delete "/api/v1/books/#{book.id}", headers: headers, as: :json

    expect(response).to have_http_status(:conflict)
    expect(json_response).to eq("error" => "Conflict")
  end
end
