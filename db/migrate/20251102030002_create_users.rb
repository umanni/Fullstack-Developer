class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.text :full_name
      t.text :email
      t.integer :role

      t.timestamps
    end
  end
end
