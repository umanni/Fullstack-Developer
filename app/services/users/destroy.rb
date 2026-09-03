module Users
  class Destroy
    LAST_ADMIN_MESSAGE = "The last administrator cannot be deleted.".freeze

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

        user.destroy
      end

      Dashboard::BroadcastStatsJob.perform_later if user.destroyed?
      user
    end

    private
      attr_reader :user

      def last_admin?
        user.admin? && @admin_ids.one?
      end

      # Administrators are always locked in the same order. Besides protecting the
      # invariant, this prevents two concurrent demotions/deletions from each
      # holding a different administrator row and deadlocking on the other one.
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
