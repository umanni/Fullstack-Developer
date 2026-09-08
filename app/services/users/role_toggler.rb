# frozen_string_literal: true

module Users
  # Toggles a user's role ("user" <-> "admin"). An admin write use case, so it
  # persists through Admin::UserForm — controllers never touch ActiveRecord for
  # a User write (DIP). The authorization question (demotable?) stays in the
  # controller/policy; this service only applies the mutation through the
  # shared validation contract (DRY single source).
  class RoleToggler
    def self.call(target)
      new.call(target)
    end

    def call(target)
      form = Admin::UserForm.new(
        {
          full_name: target.full_name,
          email_address: target.email_address,
          role: toggled_role(target),
          require_avatar: false
        },
        user: target
      )
      form.update
    end

    private

    def toggled_role(target)
      target.role == "admin" ? "user" : "admin"
    end
  end
end
