class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, admin: 1 }

  has_one_attached :avatar_image


  validates :full_name, presence: true

  after_create_commit :broadcast_dashboard_update
  after_update_commit :broadcast_dashboard_update, if: :saved_change_to_role?
  after_destroy_commit :broadcast_dashboard_update

  private

  def broadcast_dashboard_update
    Turbo::StreamsChannel.broadcast_update_to(
    "admin_dashboard_stats",
    target: "admin_dashboard_stats",
    partial: "admin/dashboard/stats",
    locals: {
      total_users: User.count,
      users_by_role: User.group(:role).count
      }
    )
  end
end
