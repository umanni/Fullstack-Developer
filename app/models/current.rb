class Current < ActiveSupport::CurrentAttributes
  attribute :session, :suppress_user_statistics_broadcasts
  delegate :user, to: :session, allow_nil: true
end
