class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable

  enum role: { non_admin: 0, admin: 1 }

  validates :full_name, :role,
    presence: true

  scope :non_admins, -> { where(role: "non_admin") }
  scope :admins, -> { where(role: "admin") }

  after_commit :flush_cache

  def flush_cache
    Rails.cache.delete([self.class.name, "admins_count"])
    Rails.cache.delete([self.class.name, "non_admins_count"])
  end

  def self.cached_admin_counts
    Rails.cache.fetch([self, "admins_count"]) { admins.count }
  end

  def self.cached_non_admin_counts
    Rails.cache.fetch([self, "non_admins_count"]) { non_admins.count }
  end
end
