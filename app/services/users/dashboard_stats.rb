module Users
  class DashboardStats
    Result = Data.define(:total, :admins, :members)

    def self.call
      new.call
    end

    def call
      counts = User.group(:role).count
      Result.new(
        total: counts.values.sum,
        admins: counts["admin"] || counts[User.roles[:admin]] || 0,
        members: counts["member"] || counts[User.roles[:member]] || 0
      )
    end
  end
end
