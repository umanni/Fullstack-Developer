class ProcessUserImportJob < ApplicationJob
  queue_as :default

  # How often progress reaches the browser. Broadcasting every row would turn a
  # thousand-row file into a thousand renders for a bar that moves a pixel.
  PROGRESS_EVERY = 10

  def perform(user_import_id)
    @import = UserImport.find(user_import_id)

    start
    process_rows
    finish
  rescue ActiveRecord::RecordNotFound
    # The import was deleted before the worker reached it. Nothing to do.
  rescue UserImportParser::UnreadableFile, UserImportParser::TooManyRows => e
    fail_import(e.message)
  end

  private

  attr_reader :import

  # Re-running is safe: counters and previous row errors are cleared first, so
  # the record describes this run rather than the sum of every run. Rows whose
  # user already exists come back as rejected duplicates instead of creating a
  # second account.
  def start
    import.row_errors.delete_all
    import.update!(
      status: :processing,
      started_at: Time.current,
      finished_at: nil,
      failure_reason: nil,
      total_rows: 0,
      processed_rows: 0,
      created_users: 0,
      rejected_rows: 0
    )
  end

  def process_rows
    # Counter broadcasts are suspended for the duration: without this the
    # dashboard would be re-rendered once per imported row.
    UserCounters.suspend_broadcasts do
      import.file.blob.open do |file|
        parser = UserImportParser.new(path: file.path, format: import.format)

        import.update!(total_rows: parser.row_count)
        broadcast_progress

        parser.each_row do |row_number, attributes|
          import_row(row_number, attributes)
        end
      end
    end
  end

  def import_row(row_number, attributes)
    user = build_user(attributes)

    if user.save
      record_creation(user)
    else
      record_rejection(row_number, attributes, user.errors.full_messages)
    end

    import.increment!(:processed_rows)
    broadcast_progress if (import.processed_rows % PROGRESS_EVERY).zero?
  rescue ArgumentError => e
    # An unknown role reaches the enum setter before validation can speak.
    record_rejection(row_number, attributes, [e.message])
    import.increment!(:processed_rows)
  end

  def build_user(attributes)
    User.new(
      full_name: attributes[:full_name],
      email_address: attributes[:email_address],
      avatar_url: attributes[:avatar_url],
      role: attributes[:role].presence || :user,
      # Imported people never receive a password from the file. They get an
      # unguessable one and set their own through the reset flow.
      password: SecureRandom.base58(32)
    )
  end

  # The account exists and its password is a random string nobody has seen, so
  # the invitation is what makes the import mean anything to the person in it.
  def record_creation(user)
    InvitationsMailer.invite(user).deliver_later
    AuditEvent.record!(action: :imported, actor: import.administrator,
                       actor_email: import.administrator_email, subject: user,
                       details: { user_import_id: import.id })
    import.increment!(:created_users)
  end

  def record_rejection(row_number, attributes, messages)
    import.row_errors.create!(
      row_number: row_number,
      email_address: attributes[:email_address],
      messages: messages
    )
    import.increment!(:rejected_rows)
  end

  def finish
    import.update!(
      status: import.rejected_rows.positive? ? :completed_with_errors : :completed,
      finished_at: Time.current
    )
    broadcast_progress
    UserCounters.broadcast
  end

  def fail_import(reason)
    import.update!(status: :failed, failure_reason: reason, finished_at: Time.current)
    broadcast_progress
  end

  def broadcast_progress
    Turbo::StreamsChannel.broadcast_replace_to(
      import.stream_name,
      target: import.dom_id,
      partial: "admin/user_imports/progress",
      locals: { user_import: import }
    )
  end
end
