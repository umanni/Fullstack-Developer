class UserBulk < ApplicationRecord
  include AASM
  
  enum state: [:enqueued, :processing, :completed]

  aasm column: :state, enum: true do
    state :enqueued, initial: true
    state :processing
    state :completed

    event :process do
      transitions from: :enqueued, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :completed
    end
  end

  has_one_attached :file

  validates :file, attached: true, content_type: ['application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  after_create :enqueue_user_bulk!

  def process_bulk!
    file.open do | opened_file |
      process! if may_process?
      spreadsheet = Roo::Excelx.new(opened_file, file_warning: :ignore)
      spreadsheet.each_row_streaming(offset: 1) do |row|
        User.create(full_name: row[0].value,
                    email: row[1].value,
                    password: row[2].value,
                    password_confirmation: row[2].value,
                    role: row[3].value )
    end
      finish! if may_finish?
    end
  end

  private
    def enqueue_user_bulk!
      UserBulkJob.perform_later(self.id)
    end
end
