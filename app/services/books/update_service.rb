module Books
  class UpdateService
    Result = Struct.new(:book, :errors, keyword_init: true) do
      def success?
        errors.nil?
      end
    end

    def self.call(book:, params:)
      new(book: book, params: params).call
    end

    def initialize(book:, params:)
      @book = book
      @params = params
    end

    def call
      normalized_params = normalize_inventory_params
      return Result.new(book: book, errors: book.errors.to_hash(true)) if normalized_params.nil?

      if book.update(normalized_params)
        Result.new(book: book)
      else
        Result.new(book: book, errors: book.errors.to_hash(true))
      end
    end

    private

    attr_reader :book, :params

    def normalize_inventory_params
      normalized = params.to_h.symbolize_keys
      has_total = normalized.key?(:total_copies)
      has_available = normalized.key?(:available_copies)
      return normalized unless has_total || has_available

      active_count = book.borrowings.active.count

      if has_total && has_available
        return normalized unless integers?(normalized[:total_copies], normalized[:available_copies])
        return normalized if normalized[:total_copies].to_i - normalized[:available_copies].to_i == active_count

        book.errors.add(:available_copies, "must satisfy total_copies - available_copies == active borrowings (#{active_count})")
        return nil
      end

      if has_available
        return normalized unless integer?(normalized[:available_copies])

        normalized[:total_copies] = normalized[:available_copies].to_i + active_count
      else
        return normalized unless integer?(normalized[:total_copies])

        available_copies = normalized[:total_copies].to_i - active_count
        if available_copies.negative?
          book.errors.add(:total_copies, "must be at least #{active_count} to cover active borrowings")
          return nil
        end

        normalized[:available_copies] = available_copies
      end

      normalized
    end

    def integers?(*values)
      values.all? { |value| integer?(value) }
    end

    def integer?(value)
      Integer(value, exception: false).present?
    end
  end
end
