require "csv"

# Builds the two CSV files this feature hands out: the blank template and the
# report of rejected rows.
module UserImportTemplate
  # A leading =, +, -, @, tab or carriage return makes a spreadsheet treat the
  # cell as a formula. Prefixing with an apostrophe keeps the text visible and
  # inert. Every cell that carries data from a file somebody uploaded goes
  # through here.
  FORMULA_PREFIXES = ["=", "+", "-", "@", "\t", "\r"].freeze

  INSTRUCTIONS = [
    "Rows beginning with # are instructions and are ignored on import.",
    "",
    "REQUIRED: full_name, email",
    "OPTIONAL: avatar_url, role",
    "",
    "email    must be unique. A row whose address already exists is rejected",
    "         and reported, and no duplicate account is created.",
    "role     either 'user' or 'admin'. Left blank it becomes 'user'.",
    "         Anything else rejects the row.",
    "avatar_url  an http or https link. The server never downloads it; the",
    "         browser loads it when the profile is shown.",
    "",
    "Imported people get an unguessable password and set their own through",
    "the 'forgot password' flow.",
    ""
  ].freeze

  EXAMPLE_ROWS = [
    ["Maria Silva", "maria.silva@example.com", "https://example.com/maria.png", "user"],
    ["João Souza", "joao.souza@example.com", "", ""],
    ["Ada Lovelace", "ada.lovelace@example.com", "", "admin"]
  ].freeze

  class << self
    def to_csv
      CSV.generate do |csv|
        INSTRUCTIONS.each { |line| csv << ["# #{line}".rstrip] }
        csv << UserImportParser::HEADERS
        EXAMPLE_ROWS.each { |row| csv << row }
      end
    end

    def rejected_rows_csv(user_import)
      CSV.generate do |csv|
        csv << %w[row_number email problems]

        user_import.row_errors.order(:row_number).each do |row_error|
          csv << [
            row_error.row_number,
            neutralise(row_error.email_address),
            neutralise(row_error.messages.join("; "))
          ]
        end
      end
    end

    def neutralise(value)
      text = value.to_s
      return text unless text.start_with?(*FORMULA_PREFIXES)

      "'#{text}"
    end
  end
end
