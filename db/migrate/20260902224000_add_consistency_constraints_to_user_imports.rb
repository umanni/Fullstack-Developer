class AddConsistencyConstraintsToUserImports < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :user_imports,
      "processed_rows <= total_rows",
      name: "user_imports_processed_within_total_check"
    add_check_constraint :user_imports,
      "succeeded_rows + failed_rows = processed_rows",
      name: "user_imports_processed_breakdown_check"
  end
end
