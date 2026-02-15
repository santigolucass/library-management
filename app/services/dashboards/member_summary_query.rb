module Dashboards
  class MemberSummaryQuery
    Result = Struct.new(:active_borrowings, :overdue_borrowings, keyword_init: true)

    def self.call(scope:, now: Time.current)
      new(scope: scope, now: now).call
    end

    def initialize(scope:, now:)
      @scope = scope
      @now = now
    end

    def call
      Result.new(
        active_borrowings: scope.active.order(:id),
        overdue_borrowings: scope.active.where("due_at < ?", now).order(:id)
      )
    end

    private

    attr_reader :scope, :now
  end
end
