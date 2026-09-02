class Session < ApplicationRecord
  belongs_to :user

  validates :user_agent, length: { maximum: 1_000 }, allow_blank: true
  validates :ip_address, length: { maximum: 45 }, allow_blank: true
end
