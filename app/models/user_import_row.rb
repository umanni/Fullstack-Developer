class UserImportRow < ApplicationRecord
  belongs_to :user_import, inverse_of: :rows
  belongs_to :user, optional: true

  enum :status, {
    pending: "pending",
    succeeded: "succeeded",
    failed: "failed"
  }, default: :pending, validate: true

  validates :row_number, presence: true, numericality: { only_integer: true, greater_than: 1 }
  validates :row_number, uniqueness: { scope: :user_import_id }
  validates :payload, presence: true
end
