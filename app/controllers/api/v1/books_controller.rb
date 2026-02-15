module Api
  module V1
    class BooksController < ApplicationController
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
