module Borrowings
  class ReturnService
    Result = Struct.new(:borrowing, :errors, keyword_init: true) do
      def success?
        errors.nil?
      end
    end

    def self.call(borrowing:, now: Time.current)
      new(borrowing: borrowing, now: now).call
    end

    def initialize(borrowing:, now:)
      @borrowing = borrowing
      @now = now
    end

    def call
      if borrowing.update(returned_at: now)
        Result.new(borrowing: borrowing)
      else
        Result.new(borrowing: borrowing, errors: borrowing.errors.to_hash(true))
      end
    end

    private

    attr_reader :borrowing, :now
  end
end
