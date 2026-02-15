module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_book, only: %i[show update destroy]

      def index
        authorize(Book)
        books = Books::SearchService.call(scope: Book.order(:id), query: params[:q])
        render json: { data: books.map { |book| book_payload(book) } }, status: :ok
      end

      def show
        authorize(@book)
        render json: { data: book_payload(@book) }, status: :ok
      end

      def create
        authorize(Book)

        book = Book.new(book_params)
        book.available_copies = book.total_copies if book.available_copies.nil?

        if book.save
          render json: { data: book_payload(book) }, status: :created
        else
          render json: { errors: book.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      def update
        authorize(@book)

        if @book.update(book_params)
          render json: { data: book_payload(@book) }, status: :ok
        else
          render json: { errors: @book.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(@book)
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
