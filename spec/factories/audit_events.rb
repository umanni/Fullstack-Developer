FactoryBot.define do
  factory :audit_event do
    actor factory: %i[user admin]
    subject factory: :user
    action { :created }

    actor_email { actor.email_address }
    subject_email { subject.email_address }
  end
end
