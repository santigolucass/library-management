class MemberDashboardPolicy < ApplicationPolicy
  def show?
    member?
  end
end
