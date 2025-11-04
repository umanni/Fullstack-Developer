class ChangeImportProgressStatusToInteger < ActiveRecord::Migration[7.0]
  def up
    # Remove any non-integer default first (Postgres can't cast string default to integer)
    execute <<-SQL.squish
      ALTER TABLE import_progresses
      ALTER COLUMN status DROP DEFAULT;
    SQL

    # Convert string values to integer enum values and change column type
    execute <<-SQL.squish
      ALTER TABLE import_progresses
      ALTER COLUMN status TYPE integer USING (
        CASE status
          WHEN 'running' THEN 0
          WHEN 'completed' THEN 1
          WHEN 'failed' THEN 2
          ELSE 0
        END
      );
    SQL

    change_column_default :import_progresses, :status, 0
  end

  def down
    # Remove default before converting back
    execute <<-SQL.squish
      ALTER TABLE import_progresses
      ALTER COLUMN status DROP DEFAULT;
    SQL

    # Revert integer back to string values
    execute <<-SQL.squish
      ALTER TABLE import_progresses
      ALTER COLUMN status TYPE character varying USING (
        CASE status
          WHEN 0 THEN 'running'
          WHEN 1 THEN 'completed'
          WHEN 2 THEN 'failed'
          ELSE 'running'
        END
      );
    SQL

    change_column_default :import_progresses, :status, 'running'
  end
end
