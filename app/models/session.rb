# == Schema Information
#
# Table name: sessions
#
#  id             :bigint           not null, primary key
#  ip_address     :string
#  last_active_at :datetime
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_sessions_on_created_at      (created_at)
#  index_sessions_on_last_active_at  (last_active_at)
#  index_sessions_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Session < ApplicationRecord
  belongs_to :user

  SESSION_TTL = 30.days

  scope :expired, -> { where("last_active_at < ?", SESSION_TTL.ago) }
  scope :active, -> { where("last_active_at >= ? OR last_active_at IS NULL", SESSION_TTL.ago) }

  def expired?
    last_active_at.present? && last_active_at < SESSION_TTL.ago
  end

  def touch_last_active!
    update_column(:last_active_at, Time.current)
  end
end
