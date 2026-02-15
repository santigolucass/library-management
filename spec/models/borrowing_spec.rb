require "rails_helper"

RSpec.describe Borrowing, type: :model do
  let!(:user) do
    User.create!(
      email: "member@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "member"
    )
  end
  let!(:book) do
    Book.create!(
      title: "1984",
      author: "George Orwell",
      genre: "Dystopian",
      isbn: "9780451524935",
      total_copies: 10,
      available_copies: 10
    )
  end

  describe "associations" do
    it { expect(described_class.reflect_on_association(:user)&.macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:book)&.macro).to eq(:belongs_to) }
  end

  describe "validations" do
    subject(:borrowing) do
      described_class.new(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 14.days.from_now,
        returned_at: nil
      )
    end

    it "is valid with required attributes" do
      expect(borrowing).to be_valid
    end

    it "requires due_at to be after borrowed_at" do
      borrowing.due_at = borrowing.borrowed_at

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:due_at]).to include("must be after borrowed_at")
    end

    it "requires returned_at to be on or after borrowed_at when present" do
      borrowing.returned_at = borrowing.borrowed_at - 1.hour

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:returned_at]).to include("must be on or after borrowed_at")
    end

    it "does not allow multiple active borrowings for the same user and book" do
      first = described_class.create!(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 7.days.from_now,
        returned_at: nil
      )

      second = described_class.new(
        user: user,
        book: book,
        borrowed_at: first.borrowed_at + 1.minute,
        due_at: first.due_at + 1.day,
        returned_at: nil
      )

      expect(second).not_to be_valid
      expect(second.errors[:book_id]).to include("already has an active borrowing for this user")
    end

    it "allows a new borrowing for the same user and book after return" do
      first = described_class.create!(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 7.days.from_now,
        returned_at: Time.current
      )

      second = described_class.new(
        user: user,
        book: book,
        borrowed_at: first.borrowed_at + 1.day,
        due_at: first.due_at + 2.days,
        returned_at: nil
      )

      expect(second).to be_valid
    end

    it "does not allow borrowing when there are no available copies" do
      book.update!(available_copies: 0)
      borrowing = described_class.new(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 14.days.from_now,
        returned_at: nil
      )

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:book_id]).to include("is unavailable")
    end
  end

  describe "callbacks" do
    it "decrements available copies on create and increments on return" do
      borrowing = described_class.create!(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 7.days.from_now,
        returned_at: nil
      )

      expect(book.reload.available_copies).to eq(9)

      borrowing.update!(returned_at: Time.current)

      expect(book.reload.available_copies).to eq(10)
    end
  end

  describe ".overdue" do
    it "returns active borrowings with past due_at only" do
      another_book = Book.create!(
        title: "Animal Farm",
        author: "George Orwell",
        genre: "Dystopian",
        isbn: "9780451526342",
        total_copies: 10,
        available_copies: 10
      )

      overdue = described_class.create!(
        user: user,
        book: book,
        borrowed_at: 10.days.ago,
        due_at: 1.day.ago,
        returned_at: nil
      )
      described_class.create!(
        user: user,
        book: another_book,
        borrowed_at: 1.day.ago,
        due_at: 7.days.from_now,
        returned_at: nil
      )
      described_class.create!(
        user: user,
        book: another_book,
        borrowed_at: 10.days.ago,
        due_at: 3.days.ago,
        returned_at: 1.day.ago
      )

      expect(described_class.overdue).to contain_exactly(overdue)
    end
  end
end
