# frozen_string_literal: true

namespace :sample do
  desc "Generate docs/sample_users.xlsx for import demos"
  task xlsx: :environment do
    require "caxlsx"

    path = Rails.root.join("docs/sample_users.xlsx")
    Axlsx::Package.new do |package|
      package.workbook.add_worksheet(name: "Users") do |sheet|
        sheet.add_row %w[full_name email password role avatar_url]
        sheet.add_row [
          "Imported Delta",
          "delta.import@example.com",
          "password123",
          "member",
          "https://api.dicebear.com/9.x/initials/svg?seed=Delta"
        ]
        sheet.add_row [
          "Imported Epsilon",
          "epsilon.import@example.com",
          "password123",
          "admin",
          "https://api.dicebear.com/9.x/initials/svg?seed=Epsilon"
        ]
      end
      package.serialize(path.to_s)
    end

    puts "Wrote #{path}"
  end
end
