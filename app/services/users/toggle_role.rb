module Users
  class ToggleRole
    LAST_ADMIN_MESSAGE = "The last administrator cannot be demoted.".freeze

    def self.call(user:)
      new(user:).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      User.transaction do
        lock_relevant_users!
        return reject_last_admin if last_admin?

        user.update(role: user.admin? ? :user : :admin)
      end

      Dashboard::BroadcastStatsJob.perform_later if user.errors.empty?
      user
    end

    private
      attr_reader :user

      def last_admin?
        user.admin? && @admin_ids.one?
      end

      def lock_relevant_users!
        if user.admin?
          @admin_ids = User.admin.order(:id).lock.pluck(:id)
        else
          user.lock!
          @admin_ids = []
        end
      end

      def reject_last_admin
        user.errors.add(:base, LAST_ADMIN_MESSAGE)
        user
      end
  end
end
