require "rails_helper"

RSpec.describe "GET /books search", type: :request do
  before { host! "localhost" }

  let!(:member) do
    User.create!(email: "search_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
  end

  let(:query_token) { "token_#{SecureRandom.hex(6)}" }
  let(:isbn_one) { "9780132350#{SecureRandom.random_number(10_000).to_s.rjust(4, '0')}" }
  let(:isbn_two) { "9780441013#{SecureRandom.random_number(10_000).to_s.rjust(4, '0')}" }
  let(:isbn_three) { "9780201616#{SecureRandom.random_number(10_000).to_s.rjust(4, '0')}" }

  let!(:book_one) do
    Book.create!(title: "Clean Code #{query_token}", author: "Robert Martin", genre: "Software", isbn: isbn_one, total_copies: 3, available_copies: 3)
  end
  let!(:book_two) do
    Book.create!(title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", isbn: isbn_two, total_copies: 2, available_copies: 2)
  end
  let!(:book_three) do
    Book.create!(title: "The Pragmatic Programmer", author: "Andy Hunt", genre: query_token, isbn: isbn_three, total_copies: 4, available_copies: 4)
  end
  let(:token) { Warden::JWTAuth::UserEncoder.new.call(member, :user, nil).first }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  it "returns all books when q is not provided" do
    get "/api/v1/books", headers: headers

    expect(response).to have_http_status(:ok)
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to include(book_one.id, book_two.id, book_three.id)
  end

  it "filters by title, author, or genre using q" do
    get "/api/v1/books", params: { q: query_token }, headers: headers

    expect(response).to have_http_status(:ok)
    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to contain_exactly(book_one.id, book_three.id)
  end

  it "orders available books before unavailable books" do
    book_two.update!(available_copies: 0)

    get "/api/v1/books", headers: headers

    ids = json_response.fetch("data").map { |item| item.fetch("id") }
    expect(ids).to eq([ book_one.id, book_three.id, book_two.id ])
  end
end
