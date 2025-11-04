class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [:username]

  # Active Storage


  validates :username, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user admin] }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum :role, { user: 0, admin: 1 }, default: :user


  has_one_attached :avatar_image

  after_initialize :set_default_role, if: :new_record?


  private

  def set_default_role
    self.role ||= "user"
  end
end
