# app/queries/dashboard/stats.rb
module Dashboard
  class Stats
    CACHE_KEY = "dashboard/stats"
    CACHE_TTL = 5.seconds

    def self.current = new.to_h
    def self.expire = Rails.cache.delete(CACHE_KEY)

    def to_h
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { compute }
    end

    private

    # `group(:role).count` keys on the enum label, so the keys line up with
    # `User.roles.keys` without any casting.
    def compute
      counts = User.group(:role).count

      {
        total: counts.values.sum,
        by_role: User.roles.keys.index_with { |role| counts.fetch(role, 0) },
        generated_at: Time.current.iso8601
      }
    end
  end
end
