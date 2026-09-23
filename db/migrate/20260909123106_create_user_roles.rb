class CreateUserRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_roles do |t|
      t.string :label
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
