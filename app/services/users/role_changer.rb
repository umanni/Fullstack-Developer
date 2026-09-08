module Users
  class RoleChanger
    class Error < StandardError; end

    def self.call(user:, actor:)
      new(user:, actor:).call
    end

    def initialize(user:, actor:)
      @user = user
      @actor = actor
    end

    def call
      raise Error, "You cannot change your own role." if user == actor

      User.transaction do
        # Serializing changes to administrators prevents concurrent requests from removing every admin.
        User.admin.lock.load
        user.lock!
        ensure_another_admin_exists! if user.admin?
        user.update!(role: user.admin? ? :user : :admin)
      end

      user
    end

    private
      attr_reader :user, :actor

      def ensure_another_admin_exists!
        raise Error, "Cannot demote the last administrator." if User.admin.count <= 1
      end
  end
end
