class User < ApplicationRecord
  has_one :user_profile, dependent: :destroy
  after_create :create_user_profile

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

 
  private 

  def create_user_profile
    UserProfile.create(user_id: self.id, full_name: self.full_name, role: self.role, avatar_image: self.avatar_image)
  end

  def user_profile_params
    params.require(:user).permit(:full_name, :avatar_image, :role)
  end

end
