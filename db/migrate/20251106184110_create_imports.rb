class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :file_name
      t.string :status
      t.integer :progress
      t.integer :total_rows
      t.integer :processed_rows
      t.text :error_details
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
