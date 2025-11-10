require "csv"
require "down"

class CsvImportService
  def initialize(file)
    @file = file
    @count = 0
  end

  def import_users
    @count = 0
    total_users_before_import = User.count
    users_to_import = []

    CSV.foreach(@file.path, headers: true) do |row|
      user = row.to_h
      users_to_import << user if user["avatar_image_url"]
    end

    User.import(users_to_import, on_duplicate_key_ignore: true)

    total_users_after_import = User.count
    @count = total_users_after_import - total_users_before_import

    attach_avatar_image_to_users(users_to_import)
  end

  def number_imported_with_last_run
    @count
  end

  private

  def attach_avatar_image_to_users(users)
    users.each do |imported_user|
      created_user = User.find_by(email: imported_user["email"])

      if created_user
        tempfile = Down.download(created_user.avatar_image_url)
        created_user.avatar_image.attach(
          io: tempfile,
          filename: tempfile.original_filename,
          content_type: tempfile.content_type
        )
      end
    end
  end
end
