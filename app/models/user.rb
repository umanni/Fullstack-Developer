class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one_attached :avatar_image
  has_many :user_imports, dependent: :destroy

  # Enums
  enum :role, { user: 0, admin: 1 }

  # Validations
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                   message: 'must be a valid URL' }, allow_blank: true

  # Scopes
  scope :by_role, ->(role) { where(role: role) }
  scope :admins, -> { where(role: :admin) }
  scope :guests, -> { where("email LIKE ? OR full_name = ?", "%@guest.temp", "Usuário Visitante") }
  scope :regular_users, -> { where(role: :user).where.not("email LIKE ? OR full_name = ?", "%@guest.temp", "Usuário Visitante") }

  # Callbacks
  after_create :broadcast_user_count
  after_update :broadcast_user_count
  after_destroy :broadcast_user_count

  # Instance methods
  def admin?
    role == 'admin'
  end

  def display_avatar
    if avatar_image.attached?
      avatar_image
    elsif avatar_url.present?
      avatar_url
    else
      'https://via.placeholder.com/150'
    end
  end

  private

  def broadcast_user_count
    AdminDashboardBroadcastJob.perform_later
  end
end
