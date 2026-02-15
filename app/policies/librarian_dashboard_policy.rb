class LibrarianDashboardPolicy < ApplicationPolicy
  def show?
    librarian?
  end
end
