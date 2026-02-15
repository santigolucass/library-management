module Dashboards
  class LibrarianSummaryQuery
    def self.call(now: Time.current)
      new(now: now).call
    end

    def initialize(now:)
      @now = now
    end

    def call
      {
        total_books: Book.count,
        total_borrowed_books: Borrowing.active.count,
        books_due_today: Borrowing.where(due_at: now.all_day).count,
        overdue_members: overdue_members
      }
    end

    private

    attr_reader :now

    def overdue_members
      Borrowing.overdue
               .joins(:user)
               .group("users.id", "users.email")
               .order(Arel.sql("COUNT(*) DESC"), "users.id ASC")
               .count
               .map do |(user_id, email), overdue_count|
        { user_id: user_id, email: email, overdue_count: overdue_count }
      end
    end
  end
end
