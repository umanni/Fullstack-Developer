class CreateUserBulks < ActiveRecord::Migration[6.0]
  def change
    create_table :user_bulks do |t|
      t.integer :state

      t.timestamps
    end
  end
end
