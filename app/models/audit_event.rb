# A record of what an administrator did to somebody else's account. Written
# from the places that perform those actions rather than from a model callback:
# the actor is a fact about the request, and a callback would have to go
# looking for it in thread-local state -- or would fire for the seeds, the
# console and the import alike, all attributed to nobody.
class AuditEvent < ApplicationRecord
  # What is written as the actor when nobody was signed in: a seed, the
  # console, a job with no administrator behind it.
  SYSTEM = "system".freeze

  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, class_name: "User", optional: true

  enum :action,
       { created: 0, updated: 1, promoted: 2, demoted: 3, deleted: 4, imported: 5 },
       validate: true

  validates :actor_email, :subject_email, presence: true

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  class << self
    # The addresses are copied here, at the moment of the event, so the trail
    # still reads once either account is gone. A deletion is recorded after the
    # fact, when the row it refers to no longer exists -- hence `persisted?`
    # rather than the record itself.
    def record!(action:, subject:, actor: nil, actor_email: nil, details: {})
      create!(
        action: action,
        actor: (actor if actor&.persisted?),
        actor_email: actor_email.presence || actor&.email_address || SYSTEM,
        subject: (subject if subject.persisted?),
        subject_email: subject.email_address,
        details: details
      )
    end

    # What an update actually changed, without the noise: the password digest
    # is not reported, and neither is a column nobody asked about.
    def changes_worth_recording(user)
      user.previous_changes.except("updated_at", "password_digest", "searchable_text")
    end
  end

  def actor_name
    actor&.full_name || actor_email
  end

  def subject_name
    subject&.full_name || subject_email
  end
end
