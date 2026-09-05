# Creates (or records the failure of) a single spreadsheet import row as a User.
#
# Imported users get an unguessable random password (never communicated) since
# they never chose one themselves; a "set your password" e-mail lets them pick a
# real one via the same token mechanism used for password resets.
class SpreadsheetImportRowImporter
  def initialize(spreadsheet_import)
    @spreadsheet_import = spreadsheet_import
  end

  # Returns true if the row created a user, false if it was recorded as an error.
  def import(row_number, data)
    user = User.new(
      email: data["email"],
      full_name: data["nome"],
      password: SecureRandom.hex(16),
      role: :no_admin,
      skip_dashboard_broadcast: true
    )

    return record_success(user) if user.save

    record_failure(row_number, data, user)
  end

  private

  attr_reader :spreadsheet_import

  def record_success(user)
    PasswordsMailer.welcome(user).deliver_later
    true
  end

  def record_failure(row_number, data, user)
    spreadsheet_import.spreadsheet_import_row_errors.create!(
      row_number: row_number,
      message: user.errors.full_messages.to_sentence,
      raw_data: data.to_json
    )
    false
  end
end
