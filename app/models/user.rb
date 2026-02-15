class User < ApplicationRecord
  ROLES = %w[librarian member].freeze

  enum :role, ROLES.index_with(&:itself), validate: true

  has_many :borrowings, dependent: :destroy
  has_many :books, through: :borrowings

  before_validation :normalize_email
  before_destroy :ensure_no_active_borrowings, prepend: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def ensure_no_active_borrowings
    return unless borrowings.active.exists?

    errors.add(:base, "cannot be deleted with active borrowings")
    throw(:abort)
  end
end
