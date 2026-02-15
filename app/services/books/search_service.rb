module Books
  class SearchService
    def self.call(scope: Book.all, query: nil)
      new(scope: scope, query: query).call
    end

    def initialize(scope:, query:)
      @scope = scope
      @query = query
    end

    def call
      return scope unless query.present?

      pattern = "%#{query.strip.downcase}%"
      scope.where(
        "LOWER(title) LIKE :q OR LOWER(author) LIKE :q OR LOWER(genre) LIKE :q",
        q: pattern
      )
    end

    private

    attr_reader :scope, :query
  end
end
