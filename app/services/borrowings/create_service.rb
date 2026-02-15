module Borrowings
  class CreateService
    DUE_IN_DAYS = 14

    Result = Struct.new(:borrowing, :error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    def self.call(user:, book_id:, now: Time.current)
      new(user: user, book_id: book_id, now: now).call
    end

    def initialize(user:, book_id:, now:)
      @user = user
      @book_id = book_id
      @now = now
    end

    def call
      borrowing = Borrowing.new(
        user: user,
        book: Book.find(book_id),
        borrowed_at: now,
        due_at: now + DUE_IN_DAYS.days,
        returned_at: nil
      )

      if borrowing.save
        Result.new(borrowing: borrowing)
      else
        Result.new(error: borrowing.errors.full_messages.to_sentence.presence || "Conflict")
      end
    end

    private

    attr_reader :user, :book_id, :now
  end
end
