class Borrowing < ApplicationRecord
  scope :active, -> { where(returned_at: nil) }

  belongs_to :user
  belongs_to :book

  validates :borrowed_at, :due_at, presence: true
  validate :due_at_after_borrowed_at
  validate :returned_at_not_before_borrowed_at

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
end
