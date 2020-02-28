# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let!(:user) { create :user, :admin }
  before do
    sign_in user
  end

  describe 'GET Show' do
    it "returns HTTP successful" do
      get profile_path
      expect(response).to be_successful
    end

    it "must include clients, miners and cases" do
      get profile_path
      expect(response.body).to include(user.full_name) &
                               include(user.email)
    end
  end
end
