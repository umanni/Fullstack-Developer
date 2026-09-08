class ProcessUserImportJob < ApplicationJob
  queue_as :imports

  limits_concurrency to: 1,
    key: ->(user_import) { user_import.id },
    duration: 30.minutes

  retry_on StandardError, wait: :polynomially_longer, attempts: 3 do |job, error|
    job.arguments.first.mark_failed!(error)
  end
  discard_on ActiveJob::DeserializationError

  def perform(user_import)
    return if user_import.completed? || user_import.completed_with_errors?

    user_import.update!(status: :processing, started_at: user_import.started_at || Time.current, failure_message: nil)
    stage_rows!(user_import) unless user_import.rows.exists?
    process_rows!(user_import)
    finish!(user_import)
  rescue UserImports::SpreadsheetReader::Error => error
    user_import.mark_failed!(error)
  end

  private
    def stage_rows!(user_import)
      timestamp = Time.current
      attributes = UserImports::SpreadsheetReader.new(user_import).each_row.map do |row_number, payload|
        {
          user_import_id: user_import.id,
          row_number:,
          payload:,
          status: "pending",
          created_at: timestamp,
          updated_at: timestamp
        }
      end
      raise UserImports::SpreadsheetReader::Error, "The spreadsheet does not contain any data rows." if attributes.empty?

      UserImport.transaction do
        UserImportRow.insert_all!(attributes)
        user_import.update!(total_rows: attributes.length)
      end
      user_import.broadcast_progress!
    end

    def process_rows!(user_import)
      interval = [ (user_import.total_rows / 100.0).ceil, 1 ].max
      Current.suppress_user_statistics_broadcasts = true

      user_import.rows.pending.find_each do |row|
        process_row!(row)
        next unless (row.row_number - 1) % interval == 0

        user_import.refresh_counters!
        user_import.broadcast_progress!
      end
    ensure
      Current.suppress_user_statistics_broadcasts = false
    end

    def process_row!(row)
      created_user = nil

      # Isolate each row in a savepoint. A uniqueness/validation error must not
      # poison the outer import transaction, otherwise later rows cannot be
      # persisted on PostgreSQL.
      User.transaction(requires_new: true) do
        row.with_lock do
          return unless row.pending?

          created_user = User.create!(
            **row.payload.symbolize_keys.slice(:full_name, :email, :role),
            password: SecureRandom.base58(24)
          )
          row.update!(status: :succeeded, user: created_user, error_message: nil)
        end
      end

      PasswordsMailer.reset(created_user).deliver_later if created_user
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => error
      message = error.respond_to?(:record) ? error.record.errors.full_messages.to_sentence : error.message
      row.reload.update!(status: :failed, error_message: message.to_s.truncate(1_000))
    end

    def finish!(user_import)
      user_import.refresh_counters!
      final_status = user_import.failed_rows.positive? ? :completed_with_errors : :completed
      user_import.update!(status: final_status, finished_at: Time.current)
      user_import.broadcast_progress!
      UserStatisticsBroadcastJob.perform_later
    end
end
