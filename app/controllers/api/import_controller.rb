class Api::ImportController < ApplicationController

  require 'csv'
  def create
    CSV.foreach(params['file'].path, {headers: true, col_sep: ';'}) do |row|
      user = row.to_hash
      User.create! user
    end
  end
end
