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
      if book.update(params)
        Result.new(book: book)
      else
        Result.new(book: book, errors: book.errors.to_hash(true))
      end
    end

    private

    attr_reader :book, :params
  end
end
