require "rails_helper"

RSpec.describe "db/seeds.rb" do
  before do
    Borrowing.delete_all
    Book.delete_all
    User.delete_all
  end

  it "creates a realistic dataset with required sizes and statuses" do
    Rails.application.load_seed

    librarian = User.find_by(role: "librarian")

    expect(librarian).to be_present
    expect(User.where(role: "member").count).to eq(100)
    expect(Book.count).to be >= 100
    expect(Borrowing.count).to eq(10_000)

    expect(Borrowing.where(returned_at: nil).count).to be > 0
    expect(Borrowing.where(returned_at: nil).where("due_at < ?", Time.current).count).to be > 0
    expect(Borrowing.where.not(returned_at: nil).count).to be > 0
    expect(Book.where(available_copies: 0).count).to be > 0
  end
end
