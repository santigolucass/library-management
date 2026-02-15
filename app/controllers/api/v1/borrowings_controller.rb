module Api
  module V1
    class BorrowingsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :set_borrowing, only: :mark_returned

      def index
        authorize(Borrowing)
        borrowings = policy_scope(Borrowing).order(:id)

        render json: { data: borrowings.map { |borrowing| borrowing_payload(borrowing) } }, status: :ok
      end

      def borrow
        authorize(Borrowing, :borrow?)

        book = Book.find(params[:book_id])
        borrowing = Borrowing.new(
          user: current_api_user,
          book: book,
          borrowed_at: Time.current,
          due_at: 14.days.from_now,
          returned_at: nil
        )

        if borrowing.save
          render json: { data: borrowing_payload(borrowing) }, status: :created
        else
          render json: { error: borrowing.errors.full_messages.to_sentence.presence || "Conflict" }, status: :conflict
        end
      end

      def mark_returned
        authorize(@borrowing, :return?)

        if @borrowing.update(returned_at: Time.current)
          render json: { data: borrowing_payload(@borrowing) }, status: :ok
        else
          render json: { errors: @borrowing.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      private

      def set_borrowing
        @borrowing = Borrowing.find(params[:id])
      end

      def borrowing_payload(borrowing)
        {
          id: borrowing.id,
          user_id: borrowing.user_id,
          book_id: borrowing.book_id,
          borrowed_at: borrowing.borrowed_at,
          due_at: borrowing.due_at,
          returned_at: borrowing.returned_at
        }
      end
    end
  end
end
