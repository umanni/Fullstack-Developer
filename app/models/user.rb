class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_one_attached :avatar

  enum role: { user: 0, admin: 1 }

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :avatar_validation

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= :user
  end

  def avatar_validation
    return unless avatar.attached?

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, 'is too large (max 5MB)')
    end

    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, 'must be a JPEG, PNG, or GIF')
    end
  end
end