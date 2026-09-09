# == Schema Information
#
# Table name: user_imports
#
#  id             :bigint           not null, primary key
#  failed_rows    :integer          default(0), not null
#  processed_rows :integer          default(0), not null
#  status         :integer          default(0), not null
#  total_rows     :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class UserImport < ApplicationRecord
  include Turbo::Broadcastable

  has_one_attached :file

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }, default: :pending

  validates :file, presence: true
end
