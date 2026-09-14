class AddFullNameIndexToUsers < ActiveRecord::Migration[8.1]
  def change
    # The admin list orders by this column on every page.
    add_index :users, :full_name
  end
end
