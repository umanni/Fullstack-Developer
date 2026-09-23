class UserRole < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :label, presence: true, uniqueness: true
  validates :is_admin, inclusion: { in: [ true, false ] }

  scope :admin_roles, -> { where(is_admin: true) }
  scope :non_admin_roles, -> { where(is_admin: false) }

  def self.admin
    find_by!(is_admin: true)
  end

  def self.non_admin
    find_by!(is_admin: false)
  end
end
