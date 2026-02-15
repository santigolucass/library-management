class BookPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def show?
    authenticated?
  end

  def create?
    librarian?
  end

  def update?
    librarian?
  end

  def destroy?
    librarian?
  end
end
