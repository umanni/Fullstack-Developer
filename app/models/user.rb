# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  full_name       :string           not null
#  password_digest :string           not null
#  role            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  include Turbo::Broadcastable

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar_image

  enum :role, { user: 0, admin: 1 }, default: :user

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_commit :broadcast_dashboard_counts, on: %i[ create update destroy ]

  private
    def broadcast_dashboard_counts
      broadcast_replace_to(
        "admin-dashboard",
        target: "dashboard-counts",
        partial: "admin/dashboard/counts",
        locals: { total_users: User.count, users_by_role: User.group(:role).count }
      )
    end
end
