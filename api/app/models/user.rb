class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :first_name, presence: true
  validates :last_name, presence: true
  # validates :image, presence: true
  validates :profile, presence: true

  enum profile: { admin: 0, client: 1 }

  def full_name
    "#{first_name} #{last_name}"
  end
end
