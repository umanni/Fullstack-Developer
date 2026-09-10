# frozen_string_literal: true

# Enforce upload size limits at the application level.
# These limits prevent abuse and protect against resource exhaustion.

MAX_AVATAR_UPLOAD_SIZE = 5.megabytes
MAX_IMPORT_FILE_SIZE = 50.megabytes
ALLOWED_IMPORT_CONTENT_TYPES = %w[
  text/csv
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
].freeze

Rails.application.config.after_initialize do
  # Global Active Storage content type allowlist for direct uploads
  # (if direct uploads are enabled in the future)
end
