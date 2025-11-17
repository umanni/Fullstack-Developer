class CsvImportUsersService
  require "csv"

  def call(file)
    file.rewind
    csv = CSV.parse(file.read, headers: true)

    csv.each do |row|
      next if User.exists?(email: row["Email Address"])

      user_hash = {
        full_name: "#{row['First Name']} #{row['Surname']}".squish,
        email: row["Email Address"],
        password: row["Password"],
        password_confirmation: row["Password"]
      }

      User.create(user_hash)
    end
  end
end
