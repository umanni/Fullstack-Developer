class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    create_enum :user_role, [ "admin", "no_admin" ]

    change_table :users do |t|
      t.enum :role, enum_type: "user_role", null: false, default: :no_admin
    end
  end
end
