class UserImportJob < ApplicationJob
  queue_as :default

  def perform(user_import)
    user_import.update!(status: :processing)
    rows = read_rows(user_import)
    user_import.update!(total_rows: rows.size)

    rows.each do |row|
      email = row["email"].to_s.strip.downcase
      if email.blank? || email == "email"
        user_import.increment!(:failed_rows)
        next
      end
      begin
        User.create!(
          full_name: row["full_name"].to_s,
          email: email,
          password: row["password"].to_s,
          password_confirmation: row["password"].to_s
        )
        user_import.increment!(:processed_rows)
      rescue ActiveRecord::RecordInvalid
        user_import.increment!(:failed_rows)
      end
      user_import.broadcast_replace_to(
        "user_import_#{user_import.id}",
        target: "user_import_progress",
        partial: "admin/user_imports/progress",
        locals: { user_import: user_import.reload }
      )
    end

    user_import.update!(status: user_import.failed_rows.positive? && user_import.processed_rows.zero? ? :failed : :completed)
  end

  private
    def read_rows(user_import)
      file = user_import.file
      ext = File.extname(file.filename.to_s).downcase
      path = ActiveStorage::Blob.service.path_for(file.key)
      if ext == ".csv"
        CSV.read(path, headers: true).map(&:to_h)
      else
        workbook = RubyXL::Parser.parse(path)
        sheet = workbook[0]
        headers = sheet[0].cells.map { |c| c&.value.to_s }
        sheet.drop(1).filter_map do |row|
          next if row.cells.all? { |c| c&.value.nil? }
          headers.zip(row.cells.map { |c| c&.value }).to_h
        end
      end
    end
end
