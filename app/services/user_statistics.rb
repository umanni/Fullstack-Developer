class UserStatistics
  def self.call
    counts = User.group(:role).count

    {
      total: counts.values.sum,
      by_role: {
        admin: counts.fetch("admin", 0),
        user: counts.fetch("user", 0)
      },
      generated_at: Time.current.iso8601
    }
  end
end
