class UserImport < ApplicationRecord
  # The extension chooses the parser; the sniffed bytes then have to be
  # consistent with it. CSV has no magic number of its own, so the rule for it
  # is "must not look like something else" rather than "must look like CSV".
  FORMATS = {
    csv: %w[text/csv text/plain application/csv application/octet-stream].freeze,
    xlsx: %w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/zip].freeze
  }.freeze

  MAX_FILE_BYTES = 5.megabytes

  # A ceiling on work accepted in one go. Without it a single upload decides how
  # long a worker is busy.
  MAX_ROWS = 10_000

  # Optional, because an administrator may be removed after running an import
  # and the history of what was imported outlives their account. The address is
  # copied onto the row so the list can still say who asked for it.
  belongs_to :administrator, class_name: "User", optional: true

  before_validation :remember_the_administrator, on: :create
  has_one_attached :file
  has_many :row_errors, class_name: "UserImportError", dependent: :destroy

  enum :status,
       { pending: 0, processing: 1, completed: 2, completed_with_errors: 3, failed: 4 },
       default: :pending, validate: true

  validates :file, presence: true
  validates :administrator_email, presence: true
  validate :acceptable_file, if: -> { attachment_changes.key?("file") }

  scope :recent_first, -> { order(created_at: :desc) }

  def format
    extension = file.filename.extension_without_delimiter.to_s.downcase
    extension.to_sym if FORMATS.key?(extension.to_sym)
  end

  # The stream the progress updates travel on. One per import, so watching a
  # running import does not mean receiving updates about every other one.
  def stream_name
    "user_import:#{id}"
  end

  def dom_id
    "user-import-#{id}"
  end

  def finished?
    completed? || completed_with_errors? || failed?
  end

  def progress_percentage
    return 0 if total_rows.zero?

    [(processed_rows * 100 / total_rows), 100].min
  end

  # What the list shows in the "requested by" column: the name while the
  # account exists, the address it was created with once it does not.
  def requested_by
    administrator&.full_name || administrator_email
  end

  private

  def remember_the_administrator
    self.administrator_email ||= administrator&.email_address
  end

  def acceptable_file
    io = uploaded_io
    return if io.nil?

    errors.add(:file, :too_large, limit: MAX_FILE_BYTES / 1.megabyte) if io.size > MAX_FILE_BYTES

    allowed = FORMATS[format]
    return errors.add(:file, :unsupported_format) if allowed.nil?

    detected = Marcel::MimeType.for(io)
    errors.add(:file, :content_mismatch) unless allowed.include?(detected)
  ensure
    io.rewind if io.respond_to?(:rewind)
  end

  def uploaded_io
    attachable = attachment_changes["file"]&.attachable
    return if attachable.blank?
    return attachable.tempfile if attachable.respond_to?(:tempfile)

    attachable if attachable.respond_to?(:size) && attachable.respond_to?(:read)
  end
end
