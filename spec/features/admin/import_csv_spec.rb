# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.feature 'admin/users/upload_csv' do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
    visit '/admin/users/upload_csv'
  end

  scenario "upload users csv" do
    csv_path = fixture_path + '/csv/users_valid.csv'
    attach_file('file', csv_path)
    click_button "Submit CSV"

    expect(page).to have_css('.flash_notice', text: 'CSV imported successfully!') &
                    have_text("csv_user1") &
                    have_text("csv_user1@email.com") &
                    have_text("csv_user2") &
                    have_text("csv_user2@email.com") &
                    have_text("csv_user3") &
                    have_text("csv_user3@email.com") &
                    have_text("csv_user4") &
                    have_text("csv_user4@email.com")
  end

  scenario "upload no csv" do
    click_button "Submit CSV"

    expect(page).to have_text('Error invalid CSV, please upload a valid CSV')
  end

  scenario "upload invalid csv" do
    csv_path = fixture_path + '/csv/users_invalid.csv'
    attach_file('file', csv_path)
    click_button "Submit CSV"

    expect(page).to have_text('Error invalid CSV, please upload a valid CSV')
  end
end
