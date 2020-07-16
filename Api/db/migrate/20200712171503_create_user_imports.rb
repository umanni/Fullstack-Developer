class CreateUserImports < ActiveRecord::Migration[5.2]
  def change
    create_table :user_imports do |t|
      t.string :name
      t.string :attachment
      t.boolean :imported, default: true 

      t.timestamps
    end
  end
end
