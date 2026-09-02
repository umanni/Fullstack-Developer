class UserImportRow < ApplicationRecord
  belongs_to :user_import, inverse_of: :rows
  belongs_to :user, optional: true

  enum :status, { pending: 0, succeeded: 1, failed: 2 }, default: :pending, validate: true

  validates :row_number, numericality: { only_integer: true, greater_than_or_equal_to: 2 },
    uniqueness: { scope: :user_import_id }
  validates :payload, presence: true
end
