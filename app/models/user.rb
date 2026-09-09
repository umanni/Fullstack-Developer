# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  avatar_url          :string
#  email               :string           not null
#  encrypted_email     :string
#  encrypted_full_name :string
#  full_name           :string           not null
#  password_digest     :string           not null
#  role                :integer          default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  # See config/initializers/encryption.rb for the demo/test key.

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar_image

  enum :role, { user: 0, admin: 1 }, default: :user

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  def avatar_display
    avatar_image.attached? ? avatar_image : avatar_url
  end

  after_commit :broadcast_dashboard_counts, on: %i[ create update destroy ]

  private
    def broadcast_dashboard_counts
      ActionCable.server.broadcast(
        "dashboard",
        { total_users: User.count, users_by_role: User.group(:role).count }
      )
    end
end
