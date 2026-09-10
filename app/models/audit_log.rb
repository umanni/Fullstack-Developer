# == Schema Information
#
# Table name: audit_logs
#
#  id             :bigint           not null, primary key
#  action         :string           not null
#  auditable_type :string
#  ip_address     :string
#  metadata       :jsonb
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  auditable_id   :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_audit_logs_on_auditable_type_and_auditable_id  (auditable_type,auditable_id)
#  index_audit_logs_on_created_at                       (created_at)
#  index_audit_logs_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#
class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Nullify user_id when user is deleted (instead of destroying audit logs)
  before_destroy :nullify_user_references, if: :user_id?

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc).limit(100) }

  def self.log!(action:, user: nil, auditable: nil, metadata: {}, request: nil)
    create!(
      action: action,
      user: user,
      auditable: auditable,
      metadata: metadata,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  private
    def nullify_user_references
      # This is called when the audit log itself is destroyed,
      # not when the user is destroyed. For user deletion,
      # we handle this via ActiveRecord callback.
    end
end
