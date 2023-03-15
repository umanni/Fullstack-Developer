class User < ApplicationRecord
  validates :full_name, presence: { message: "Your full name is required." }
  validates :email, presence: { message: "Your email is required." }, uniqueness: { message: "Has already been taken." }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Must be a valid email address." }
  validates :role, presence: true, inclusion: { in: %w(admin user) , message: "Your role is required." }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    admin: 1,
    user: 2
  }
end
