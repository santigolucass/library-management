require "rails_helper"

RSpec.describe "Dashboard query performance", type: :request do
  PASSWORD = "password123".freeze
  LIBRARIAN_DASHBOARD_MAX_SECONDS = 0.75
  MEMBER_DASHBOARD_MAX_SECONDS = 1.0

  let!(:librarian) do
    User.create!(email: "perf_librarian@example.com", password: PASSWORD, password_confirmation: PASSWORD, role: "librarian")
  end
  let!(:member) do
    User.create!(email: "perf_member@example.com", password: PASSWORD, password_confirmation: PASSWORD, role: "member")
  end

  before do
    seed_dashboard_heavy_data!
  end

  it "responds quickly for librarian dashboard under load" do
    elapsed = elapsed_seconds do
      get "/api/v1/dashboard/librarian", headers: auth_headers_for(email: librarian.email, password: PASSWORD), as: :json
      expect(response).to have_http_status(:ok)
    end

    expect(elapsed).to be < LIBRARIAN_DASHBOARD_MAX_SECONDS
  end

  it "responds quickly for member dashboard under load" do
    elapsed = elapsed_seconds do
      get "/api/v1/dashboard/member", headers: auth_headers_for(email: member.email, password: PASSWORD), as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.fetch("active_borrowings")).to be_an(Array)
      expect(json_response.fetch("overdue_borrowings")).to be_an(Array)
    end

    expect(elapsed).to be < MEMBER_DASHBOARD_MAX_SECONDS
  end

  def elapsed_seconds
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
  end

  def seed_dashboard_heavy_data!
    books = 120.times.map do |idx|
      Book.create!(
        title: "Perf Book #{idx}",
        author: "Perf Author #{idx}",
        genre: "Testing",
        isbn: format("978100000%04d", idx),
        total_copies: 40,
        available_copies: 40
      )
    end

    members = 80.times.map do |idx|
      User.create!(
        email: "perf_member_#{idx}@example.com",
        password: PASSWORD,
        password_confirmation: PASSWORD,
        role: "member"
      )
    end

    now = Time.current
    active_pairs = {}

    1200.times do |idx|
      user = members[idx % members.size]
      book = books[idx % books.size]
      pair_key = [ user.id, book.id ]
      due_at = idx % 3 == 0 ? now - (idx % 7 + 1).days : now + (idx % 10 + 1).days
      returned_at = active_pairs[pair_key] ? (now - 1.day) : nil

      Borrowing.create!(
        user: user,
        book: book,
        borrowed_at: due_at - 14.days,
        due_at: due_at,
        returned_at: returned_at
      )
      active_pairs[pair_key] = true if returned_at.nil?
    end

    40.times do |idx|
      Borrowing.create!(
        user: member,
        book: books[idx % books.size],
        borrowed_at: now - (idx + 2).days,
        due_at: idx.even? ? now - (idx % 5 + 1).days : now + (idx % 5 + 1).days,
        returned_at: nil
      )
    end
  end
end
