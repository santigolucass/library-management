require "rails_helper"

RSpec.describe Book, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:borrowings)&.macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:users)&.macro).to eq(:has_many) }
  end

  describe "validations" do
    subject(:book) do
      described_class.new(
        title: "The Hobbit",
        author: "J.R.R. Tolkien",
        genre: "Fantasy",
        isbn: "9780007525492",
        total_copies: 3,
        available_copies: 3
      )
    end

    it "is valid with required attributes" do
      expect(book).to be_valid
    end

    it "requires ISBN to be unique" do
      described_class.create!(
        title: "Dune",
        author: "Frank Herbert",
        genre: "Sci-Fi",
        isbn: "9780441013593",
        total_copies: 2,
        available_copies: 2
      )

      duplicate = described_class.new(
        title: "Dune Messiah",
        author: "Frank Herbert",
        genre: "Sci-Fi",
        isbn: "9780441013593",
        total_copies: 2,
        available_copies: 2
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:isbn]).to be_present
    end

    it "does not allow negative total_copies" do
      book.total_copies = -1

      expect(book).not_to be_valid
      expect(book.errors[:total_copies]).to be_present
    end

    it "does not allow negative available_copies" do
      book.available_copies = -1

      expect(book).not_to be_valid
      expect(book.errors[:available_copies]).to be_present
    end

    it "does not allow available_copies greater than total_copies" do
      book.available_copies = 4

      expect(book).not_to be_valid
      expect(book.errors[:available_copies]).to include("must be less than or equal to total copies")
    end
  end
end
