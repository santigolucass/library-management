# frozen_string_literal: true

TOTAL_MEMBERS = 100
TOTAL_BOOKS = 300
TOTAL_BORROWINGS = 10_000
ACTIVE_BORROWINGS = 2_500
OVERDUE_BORROWINGS = 1_500
RETURNED_BORROWINGS = TOTAL_BORROWINGS - ACTIVE_BORROWINGS - OVERDUE_BORROWINGS
DEFAULT_PASSWORD = "123123123"

now = Time.current

Borrowing.delete_all
Book.delete_all
User.delete_all

librarian = User.create!(
  email: "librarian@demo.local",
  password: DEFAULT_PASSWORD,
  password_confirmation: DEFAULT_PASSWORD,
  role: "librarian"
)

members = Array.new(TOTAL_MEMBERS) do |index|
  User.create!(
    email: format("member%03d@demo.local", index + 1),
    password: DEFAULT_PASSWORD,
    password_confirmation: DEFAULT_PASSWORD,
    role: "member"
  )
end

book_rows = Array.new(TOTAL_BOOKS) do |index|
  {
    title: "Book #{index + 1}",
    author: "Author #{(index % 40) + 1}",
    genre: ["Software", "Sci-Fi", "History", "Fantasy", "Biography"][index % 5],
    isbn: format("978000%07d", index + 1),
    total_copies: 60,
    available_copies: 60,
    created_at: now,
    updated_at: now
  }
end

Book.insert_all!(book_rows)

books = Book.order(:id).to_a
member_ids = members.map(&:id)
book_ids = books.map(&:id)

non_returned_count = ACTIVE_BORROWINGS + OVERDUE_BORROWINGS
non_returned_pairs = member_ids.product(book_ids).sample(non_returned_count)

borrow_rows = []

non_returned_pairs.first(ACTIVE_BORROWINGS).each do |user_id, book_id|
  borrowed_at = rand(1..14).days.ago

  borrow_rows << {
    user_id: user_id,
    book_id: book_id,
    borrowed_at: borrowed_at,
    due_at: rand(1..21).days.from_now,
    returned_at: nil,
    created_at: now,
    updated_at: now
  }
end

non_returned_pairs.drop(ACTIVE_BORROWINGS).each do |user_id, book_id|
  borrowed_at = rand(15..45).days.ago

  borrow_rows << {
    user_id: user_id,
    book_id: book_id,
    borrowed_at: borrowed_at,
    due_at: rand(1..14).days.ago,
    returned_at: nil,
    created_at: now,
    updated_at: now
  }
end

RETURNED_BORROWINGS.times do
  borrowed_at = rand(30..180).days.ago
  returned_at = borrowed_at + rand(1..20).days

  borrow_rows << {
    user_id: member_ids.sample,
    book_id: book_ids.sample,
    borrowed_at: borrowed_at,
    due_at: borrowed_at + 14.days,
    returned_at: returned_at,
    created_at: now,
    updated_at: now
  }
end

Borrowing.insert_all!(borrow_rows)

active_counts = Borrowing.active.group(:book_id).count

Book.find_each do |book|
  active_count = active_counts.fetch(book.id, 0)
  desired_available = [book.total_copies - active_count, 0].max

  next if book.available_copies == desired_available

  book.update_columns(available_copies: desired_available, updated_at: now)
end

puts "Seeded #{User.count} users (1 librarian + #{TOTAL_MEMBERS} members), #{Book.count} books, #{Borrowing.count} borrowings."
puts "Active: #{Borrowing.active.where('due_at >= ?', Time.current).count}, Overdue: #{Borrowing.overdue.count}, Returned: #{Borrowing.where.not(returned_at: nil).count}"
puts "Librarian login: #{librarian.email} / #{DEFAULT_PASSWORD}"
