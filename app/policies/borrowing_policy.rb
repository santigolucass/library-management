class BorrowingPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def borrow?
    member?
  end

  def return?
    librarian?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.librarian?
      return scope.where(user_id: user.id) if user&.member?

      scope.none
    end
  end
end
