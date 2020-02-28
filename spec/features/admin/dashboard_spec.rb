# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'admin/users' do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  feature 'Counters' do
    scenario 'render counters' do
      visit '/admin/dashboard'
      expect(page).to have_text("Users Count")
    end
  end
end
