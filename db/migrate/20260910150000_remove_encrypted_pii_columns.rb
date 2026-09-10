# frozen_string_literal: true

# Release It! — Remove dead encrypted_email and encrypted_full_name columns.
# These were added to the schema but never used. This migration cleans them up.

class RemoveEncryptedPiiColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :encrypted_email, :string
    remove_column :users, :encrypted_full_name, :string
  end
end
