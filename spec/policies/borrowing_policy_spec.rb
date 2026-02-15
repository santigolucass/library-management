require "rails_helper"

RSpec.describe BorrowingPolicy do
  describe ".Scope" do
    let!(:book) do
      Book.create!(title: "Scope Book", author: "Author", genre: "Genre", isbn: "9783999999902", total_copies: 3, available_copies: 3)
    end

    it "returns none for unauthenticated users" do
      Borrowing.create!(
        user: User.create!(email: "scope_member@example.com", password: "password123", password_confirmation: "password123", role: "member"),
        book: book,
        borrowed_at: Time.current,
        due_at: 2.weeks.from_now
      )

      resolved = described_class::Scope.new(nil, Borrowing.all).resolve

      expect(resolved).to be_empty
    end
  end
end
