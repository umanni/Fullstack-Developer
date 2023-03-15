class UserProfile < ApplicationRecord
  belongs_to :user

  enum role: {
    admin: 1,
    user: 2
  }
end
