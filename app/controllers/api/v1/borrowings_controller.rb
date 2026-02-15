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
        result = Borrowings::CreateService.call(user: current_api_user, book_id: params[:book_id], now: Time.current)

        if result.success?
          render json: { data: borrowing_payload(result.borrowing) }, status: :created
        else
          render json: { error: result.error }, status: :conflict
        end
      end

      def mark_returned
        authorize(@borrowing, :return?)
        result = Borrowings::ReturnService.call(borrowing: @borrowing, now: Time.current)

        if result.success?
          render json: { data: borrowing_payload(result.borrowing) }, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
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
