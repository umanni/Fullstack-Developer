module Dashboard
  class Stats
    Result = Data.define(:total, :admins, :users)

    def self.call
      counts = User.group(:role).count
      Result.new(total: counts.values.sum, admins: counts.fetch("admin", 0), users: counts.fetch("user", 0))
    end
  end
end
