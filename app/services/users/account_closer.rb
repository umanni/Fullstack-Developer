# frozen_string_literal: true

module Users
  # Closes an account: destroys the user. Sessions fall with
  # dependent: :destroy; user_imports are kept via dependent: :nullify so the
  # import history survives. Session/cookie cleanup stays in the controller.
  class AccountCloser
    def self.call(user)
      new.call(user)
    end

    def call(user)
      user.destroy!
    end
  end
end
