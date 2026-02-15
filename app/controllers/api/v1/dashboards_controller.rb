module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :authenticate_api_user!

      def librarian
        authorize(:librarian_dashboard, :show?, policy_class: LibrarianDashboardPolicy)

        overdue_members = Borrowing.overdue
                                  .joins(:user)
                                  .group("users.id", "users.email")
                                  .order(Arel.sql("COUNT(*) DESC"), "users.id ASC")
                                  .count
                                  .map do |(user_id, email), overdue_count|
          { user_id: user_id, email: email, overdue_count: overdue_count }
        end

        render json: {
          total_books: Book.count,
          total_borrowed_books: Borrowing.active.count,
          books_due_today: Borrowing.where(due_at: Time.current.all_day).count,
          overdue_members: overdue_members
        }, status: :ok
      end

      def member
        authorize(:member_dashboard, :show?, policy_class: MemberDashboardPolicy)

        scope = policy_scope(Borrowing)

        render json: {
          active_borrowings: scope.active.order(:id).map { |borrowing| borrowing_payload(borrowing) },
          overdue_borrowings: scope.active.where("due_at < ?", Time.current).order(:id).map { |borrowing| borrowing_payload(borrowing) }
        }, status: :ok
      end

      private

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
