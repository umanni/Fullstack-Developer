# One rejected row, kept so the operator can see exactly which line to fix and
# why. The email address is stored as it appeared in the file rather than
# normalised, because the point is to help somebody find it again.
class UserImportError < ApplicationRecord
  belongs_to :user_import

  validates :row_number, numericality: { only_integer: true, greater_than: 0 }
  validates :messages, presence: true
end
