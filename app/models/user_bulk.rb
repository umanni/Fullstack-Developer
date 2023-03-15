class UserBulk < ApplicationRecord
  validates :csv_file, presence: true

  mount_uploader :csv_file, CsvFileUploader

  def process_csv_file!
    return false unless csv_file.present?

    Roo::CSV.new(csv_file.current_path).each do |row|
      email = row[0]
      full_name = row[1]
      role = row[2]

      User.create(email: email, full_name: full_name, role: role, password: '123mudar')
    end

    true
  rescue StandardError => e
    Rails.logger.error("Failed to process CSV file: #{e.message}")
    false
  end
end
