module Api
  module V1
    class BooksController < ApplicationController
      REQUIRED_UPDATE_FIELDS = %i[title author genre isbn total_copies].freeze

      before_action :authenticate_api_user!
      before_action :set_book, only: %i[show update destroy]

      def index
        authorize(Book)
        availability_order_sql = "CASE WHEN available_copies > 0 THEN 0 ELSE 1 END"
        books = Books::SearchService.call(scope: Book.order(Arel.sql(availability_order_sql), :id), query: params[:q])
        render json: { data: books.map { |book| book_payload(book) } }, status: :ok
      end

      def show
        authorize(@book)
        render json: { data: book_payload(@book) }, status: :ok
      end

      def create
        authorize(Book)

        result = Books::CreateService.call(params: book_params)

        if result.success?
          render json: { data: book_payload(result.book) }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      def update
        authorize(@book)
        if missing_update_fields.any?
          render json: { errors: required_update_field_errors }, status: :unprocessable_content
          return
        end

        result = Books::UpdateService.call(book: @book, params: book_params)

        if result.success?
          render json: { data: book_payload(result.book) }, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      def destroy
        authorize(@book)
        if @book.borrowings.active.exists?
          render json: { error: "Book has active borrowings" }, status: :conflict
          return
        end

        @book.borrowings.where.not(returned_at: nil).delete_all
        @book.destroy!
        head :no_content
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.permit(:title, :author, :genre, :isbn, :total_copies, :available_copies)
      end

      def missing_update_fields
        @missing_update_fields ||= REQUIRED_UPDATE_FIELDS.reject { |field| book_params.key?(field) }
      end

      def required_update_field_errors
        missing_update_fields.index_with { [ "is required" ] }
      end

      def book_payload(book)
        {
          id: book.id,
          title: book.title,
          author: book.author,
          genre: book.genre,
          isbn: book.isbn,
          total_copies: book.total_copies,
          available_copies: book.available_copies
        }
      end
    end
  end
end
