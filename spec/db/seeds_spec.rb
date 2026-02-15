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
    expect(User.where(role: "member").count).to eq(30)
    expect(Book.count).to eq(50)
    expect(Borrowing.count).to eq(1_000)

    expect(Borrowing.where(returned_at: nil).count).to be > 0
    expect(Borrowing.where(returned_at: nil).where("due_at < ?", Time.current).count).to be > 0
    expect(Borrowing.where.not(returned_at: nil).count).to be > 0
    expect(Book.where(available_copies: 0).count).to be > 0

    expect(User.where(role: "member").first.email).not_to match(/\Amember\d{3}@demo\.local\z/)
    expect(Book.first.title).not_to match(/\ABook \d+\z/)
    expect(Book.first.author).not_to match(/\AAuthor \d+\z/)
  end
end
