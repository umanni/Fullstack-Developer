module Users
  class Create
    def self.call(attributes:, invite: false, broadcast: true)
      new(attributes:, invite:, broadcast:).call
    end

    def initialize(attributes:, invite:, broadcast:)
      @attributes = attributes
      @invite = invite
      @broadcast = broadcast
    end

    def call
      user = User.new(attributes)
      assign_random_password(user) if invite

      if user.save
        Dashboard::BroadcastStatsJob.perform_later if broadcast
        PasswordsMailer.invitation(user).deliver_later if invite
      end

      user
    end

    private
      attr_reader :attributes, :invite, :broadcast

      def assign_random_password(user)
        password = SecureRandom.base58(32)
        user.password = password
        user.password_confirmation = password
      end
  end
end
