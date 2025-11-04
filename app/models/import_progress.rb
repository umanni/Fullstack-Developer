class ImportProgress < ApplicationRecord
  # Use positional enum form to avoid Ruby keyword-argument parsing issues
  enum :status, { running: 0, completed: 1, failed: 2 }
end
