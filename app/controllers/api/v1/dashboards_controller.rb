module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :authenticate_api_user!

      def librarian
        authorize(:librarian_dashboard, :show?, policy_class: LibrarianDashboardPolicy)
        render json: Dashboards::LibrarianSummaryQuery.call(now: Time.current), status: :ok
      end

      def member
        authorize(:member_dashboard, :show?, policy_class: MemberDashboardPolicy)
        result = Dashboards::MemberSummaryQuery.call(scope: policy_scope(Borrowing), now: Time.current)

        render json: {
          active_borrowings: result.active_borrowings.map { |borrowing| borrowing_payload(borrowing) },
          overdue_borrowings: result.overdue_borrowings.map { |borrowing| borrowing_payload(borrowing) }
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
