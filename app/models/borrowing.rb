class Borrowing < ApplicationRecord
  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where("due_at < ?", Time.current) }

  belongs_to :user
  belongs_to :book

  validates :borrowed_at, :due_at, presence: true
  validate :due_at_after_borrowed_at
  validate :returned_at_not_before_borrowed_at
  validate :single_active_borrowing_per_user_and_book, if: :active_borrowing?
  validate :book_must_have_available_copy, if: :active_borrowing?

  after_create :decrement_available_copies!
  after_update_commit :increment_available_copies_on_return

  private

  def due_at_after_borrowed_at
    return if due_at.blank? || borrowed_at.blank?
    return if due_at > borrowed_at

    errors.add(:due_at, "must be after borrowed_at")
  end

  def returned_at_not_before_borrowed_at
    return if returned_at.blank? || borrowed_at.blank?
    return if returned_at >= borrowed_at

    errors.add(:returned_at, "must be on or after borrowed_at")
  end

  def active_borrowing?
    returned_at.nil?
  end

  def single_active_borrowing_per_user_and_book
    scope = self.class.active.where(user_id: user_id, book_id: book_id)
    scope = scope.where.not(id: id) if persisted?
    return unless scope.exists?

    errors.add(:book_id, "already has an active borrowing for this user")
  end

  def book_must_have_available_copy
    return if book.blank?
    return if persisted?
    return if book.available_copies.positive?

    errors.add(:book_id, "is unavailable")
  end

  def decrement_available_copies!
    book.with_lock do
      book.reload
      book.update!(available_copies: book.available_copies - 1)
    end
  end

  def increment_available_copies_on_return
    return unless saved_change_to_returned_at?
    return if returned_at_before_last_save.present?
    return if returned_at.blank?

    book.with_lock do
      book.reload
      book.update!(available_copies: book.available_copies + 1)
    end
  end
end
