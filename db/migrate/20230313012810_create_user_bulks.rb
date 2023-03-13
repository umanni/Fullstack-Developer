class CreateUserBulks < ActiveRecord::Migration[7.1]
  def change
    create_table :user_bulks do |t|
      t.integer :status

      t.timestamps
    end
  end
end
