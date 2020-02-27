# frozen_string_literal: true

require 'csv'

module ImportUsersCsvHelper

  module_function

  def import_csv(dump)
    return false if dump.nil?

    User.transaction do
      users_data = CSV.open(dump.path, headers: :first_row).map(&:to_h)
      User.create!(users_data)
      true
    rescue
      false
    end
  end
end

