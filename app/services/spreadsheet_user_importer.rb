require "csv"
require "roo"

class SpreadsheetUserImporter
  REQUIRED_HEADERS = %w[full_name email].freeze

  def initialize(import)
    @import = import
  end

  def call
    rows = parse_rows
    @import.mark_processing!(rows.size)

    rows.each do |row|
      create_user_from_row(row)
    end

    @import.mark_completed!
    DashboardChannel.broadcast_stats
  rescue StandardError => e
    @import.mark_failed!(e.message)
    raise
  end

  private

  def parse_rows
    blob = @import.spreadsheet.download
    filename = @import.filename.to_s.downcase

    if filename.end_with?(".xlsx", ".xls")
      parse_xlsx(blob)
    else
      parse_csv(blob)
    end
  end

  def parse_csv(blob)
    table = CSV.parse(blob, headers: true)
    validate_headers!(table.headers)
    table.map { |row| row.to_h.transform_keys { |k| k.to_s.strip.downcase } }
  end

  def parse_xlsx(blob)
    Tempfile.create([ "import", File.extname(@import.filename) ]) do |tmp|
      tmp.binmode
      tmp.write(blob)
      tmp.flush

      sheet = Roo::Spreadsheet.open(tmp.path)
      headers = sheet.row(1).map { |h| h.to_s.strip.downcase }
      validate_headers!(headers)

      (2..sheet.last_row).map do |i|
        values = sheet.row(i)
        headers.zip(values).to_h
      end
    end
  end

  def validate_headers!(headers)
    normalized = Array(headers).map { |h| h.to_s.strip.downcase }
    missing = REQUIRED_HEADERS - normalized
    raise ArgumentError, "Colunas obrigatórias ausentes: #{missing.join(', ')}" if missing.any?
  end

  def create_user_from_row(row)
    password = row["password"].presence || SecureRandom.alphanumeric(12)
    role = if row["role"].to_s.downcase.in?(%w[admin true yes])
      UserRole.admin
    else
      UserRole.non_admin
    end

    user = User.new(
      full_name: row["full_name"],
      email: row["email"],
      password: password,
      password_confirmation: password,
      avatar_url: row["avatar_url"].presence,
      user_role: role
    )

    if user.save
      @import.increment_progress!(success: true)
    else
      errors = (@import.row_errors || []) + [ { email: row["email"], errors: user.errors.full_messages } ]
      @import.update!(row_errors: errors)
      @import.increment_progress!(success: false)
    end
  end
end
