class UserImport < ApplicationRecord
  include Turbo::Broadcastable

  has_one_attached :file
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :file, content_type: [
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "text/csv"
  ]
end
