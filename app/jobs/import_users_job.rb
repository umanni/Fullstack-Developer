class ImportUsersJob < ApplicationJob
  queue_as :default

  def perform(user_import)
    user_import.update!(status: :processing, processed_count: 0, error_log: "")

    user_import.broadcast_replace_to(
      user_import,
      target: "user_import_status",
      partial: "admin/user_imports/status",
      locals: { user_import: user_import }
    )

    errors = []
    processed = 0

    begin
      user_import.file.open do |tempfile|
        file_ext = user_import.file.filename.extension.to_sym

        spreadsheet = Roo::Spreadsheet.open(tempfile.path, extension: file_ext)

        user_import.update!(total_count: spreadsheet.last_row - 1)

        spreadsheet.each_with_index do |row, idx|
          next if idx == 0 # Skip header row

          full_name, email = row[0], row[1]

          user = User.new(
            full_name: full_name,
            email: email,
            password: SecureRandom.hex(10)
          )

          if user.save
            processed += 1
          else
            errors << "Row #{idx + 1}: #{user.errors.full_messages.join(', ')}"
          end

          if processed % 10 == 0 || idx == spreadsheet.last_row - 1
            user_import.update!(processed_count: processed)
            user_import.broadcast_update_to(
              user_import,
              target: "import_progress_bar",
              partial: "admin/user_imports/progress",
              locals: { import: user_import }
            )
          end
        end # end spreadsheet.each

        user_import.update!(status: :completed, error_log: errors.join("\n"))
      end

    rescue => e
      user_import.update!(status: :failed, error_log: "Fatal error: #{e.message}")
    ensure
      user_import.broadcast_replace_to(
        user_import,
        target: "user_import_status",
        partial: "admin/user_imports/status",
        locals: { user_import: user_import }
      )
    end
  end
end
