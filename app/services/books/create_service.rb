module Books
  class CreateService
    Result = Struct.new(:book, :errors, keyword_init: true) do
      def success?
        errors.nil?
      end
    end

    def self.call(params:)
      new(params: params).call
    end

    def initialize(params:)
      @params = params
    end

    def call
      book = Book.new(params)

      if book.save
        Result.new(book: book)
      else
        Result.new(book: book, errors: book.errors.to_hash(true))
      end
    end

    private

    attr_reader :params
  end
end
