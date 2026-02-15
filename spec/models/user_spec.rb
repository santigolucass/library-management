require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:borrowings)&.macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:books)&.macro).to eq(:has_many) }
  end

  describe "validations" do
    subject(:user) { described_class.new(email: "user@example.com", role: "member") }

    it "is valid with email and supported role" do
      expect(user).to be_valid
    end

    it "requires email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "normalizes email to lowercase" do
      user.email = "User@Example.COM"
      user.validate

      expect(user.email).to eq("user@example.com")
    end

    it "requires unique email case-insensitively" do
      described_class.create!(email: "user@example.com", role: "member")
      duplicate = described_class.new(email: "USER@example.com", role: "librarian")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "requires a supported role" do
      user.role = "guest"

      expect(user).not_to be_valid
      expect(user.errors[:role]).to be_present
    end
  end

  describe "deletion rules" do
    let(:user) { described_class.create!(email: "delete_me@example.com", role: "member") }
    let(:book) do
      Book.create!(
        title: "Clean Code",
        author: "Robert C. Martin",
        genre: "Software",
        isbn: "9780132350884",
        total_copies: 3,
        available_copies: 3
      )
    end

    it "prevents deleting a user with active borrowings" do
      Borrowing.create!(
        user: user,
        book: book,
        borrowed_at: Time.current,
        due_at: 7.days.from_now,
        returned_at: nil
      )

      expect { user.destroy }.not_to change(described_class, :count)
      expect(user).not_to be_destroyed
      expect(user.errors[:base]).to include("cannot be deleted with active borrowings")
    end

    it "allows deleting a user when borrowings are only historical" do
      Borrowing.create!(
        user: user,
        book: book,
        borrowed_at: Time.current - 10.days,
        due_at: Time.current - 3.days,
        returned_at: Time.current - 2.days
      )

      expect { user.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe "database constraints" do
    it "rejects non-canonical email values at the database layer" do
      expect do
        described_class.connection.execute(<<~SQL)
          INSERT INTO users (email, role, created_at, updated_at)
          VALUES ('MixedCase@Example.com', 'member', NOW(), NOW())
        SQL
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
