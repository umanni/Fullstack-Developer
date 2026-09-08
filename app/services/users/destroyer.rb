module Users
  class Destroyer
    class Error < StandardError; end

    def self.call(user:, actor:, allow_self: false)
      new(user:, actor:, allow_self:).call
    end

    def initialize(user:, actor:, allow_self:)
      @user = user
      @actor = actor
      @allow_self = allow_self
    end

    def call
      if user == actor && !allow_self
        raise Error, "Delete your own account from the profile page."
      end

      User.transaction do
        User.admin.lock.load
        user.lock!
        ensure_another_admin_exists! if user.admin?
        user.destroy!
      end
    end

    private
      attr_reader :user, :actor, :allow_self

      def ensure_another_admin_exists!
        raise Error, "The last administrator cannot be deleted." if User.admin.count <= 1
      end
  end
end
