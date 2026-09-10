# frozen_string_literal: true

class AddIndexOnCreatedAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_index :sessions, :created_at
  end
end
