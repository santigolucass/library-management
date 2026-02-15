librarian = User.find_or_initialize_by(email: "librarian@demo.local")
librarian.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  role: "librarian"
)
librarian.save!

member = User.find_or_initialize_by(email: "member@demo.local")
member.assign_attributes(
  password: "password123",
  password_confirmation: "password123",
  role: "member"
)
member.save!

books = [
  { title: "Clean Architecture", author: "Robert C. Martin", genre: "Software", isbn: "9780134494166", total_copies: 4 },
  { title: "The Pragmatic Programmer", author: "David Thomas", genre: "Software", isbn: "9780135957059", total_copies: 3 },
  { title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", isbn: "9780441013593", total_copies: 2 }
]

book_records = books.map do |attrs|
  book = Book.find_or_initialize_by(isbn: attrs[:isbn])
  book.assign_attributes(attrs.merge(available_copies: attrs[:total_copies]))
  book.save!
  book
end

active = Borrowing.find_or_initialize_by(
  user_id: member.id,
  book_id: book_records.first.id,
  returned_at: nil
)
active.borrowed_at ||= 3.days.ago
active.due_at ||= 11.days.from_now
active.save!

overdue = Borrowing.find_or_initialize_by(
  user_id: member.id,
  book_id: book_records.second.id,
  returned_at: nil
)
overdue.borrowed_at ||= 20.days.ago
overdue.due_at ||= 6.days.ago
overdue.save!

Book.find_each do |book|
  active_count = book.borrowings.active.count
  desired_available = [ book.total_copies - active_count, 0 ].max
  next if book.available_copies == desired_available

  book.update!(available_copies: desired_available)
end
