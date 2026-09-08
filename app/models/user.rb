class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_imports, dependent: :nullify
  has_one_attached :avatar

  enum :role, { user: 0, admin: 1 }

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true

  def avatar_source
    return avatar if avatar.attached?
    avatar_url
  end
end
