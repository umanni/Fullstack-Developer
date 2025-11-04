
class CreateImportProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :import_progresses do |t|
      t.integer :total, default: 0
      t.integer :processed, default: 0
  # status is an enum (running: 0, completed: 1, failed: 2)
  # store as integer with numeric default
  t.integer :status, default: 0

      t.timestamps
    end
  end
end
