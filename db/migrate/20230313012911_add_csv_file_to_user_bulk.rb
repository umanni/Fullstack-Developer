class AddCsvFileToUserBulk < ActiveRecord::Migration[7.1]
  def change
    add_column :user_bulks, :csv_file, :string
  end
end
