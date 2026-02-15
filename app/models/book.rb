class Book < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_exception
  has_many :users, through: :borrowings

  before_validation :default_available_copies

  validates :title, :author, :genre, :isbn, presence: true
  validates :isbn, uniqueness: true
  validates :total_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :available_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :available_copies_within_total

  private

  def default_available_copies
    return unless available_copies.nil?
    return if total_copies.nil?

    self.available_copies = total_copies
  end

  def available_copies_within_total
    return if available_copies.blank? || total_copies.blank?
    return if available_copies <= total_copies

    errors.add(:available_copies, "must be less than or equal to total copies")
  end
end
