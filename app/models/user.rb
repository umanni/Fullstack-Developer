class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,  :trackable,
         :recoverable, :rememberable, :validatable

  enum role: { non_admin: 0, admin: 1 }

  validates :full_name, :role,
    presence: true

  scope :non_admins, -> { where(role: "non_admin") }
  scope :admins, -> { where(role: "admin") }
end
