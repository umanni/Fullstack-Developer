require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe "POST #new_bulk_users" do
    let(:user) { create(:user) }
    
    # Sign in user before each test
    before do
      sign_in user
    end

    # Test for valid CSV file
    context "with valid CSV file" do
      let(:csv_file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'valid_users.csv'), 'text/csv') }

      it "creates users from CSV file" do # This test passes
        expect {
          post :new_bulk_users, params: { user_bulk: { csv_file: csv_file } }
        }.to change(User, :count).by(2)

        expect(response).to redirect_to(dashboard_path)
        expect(flash[:success]).to eq('Users imported successfully.')
      end
    end

    # Test for invalid CSV file
    context "with invalid CSV file" do
      let(:csv_file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'invalid_users.csv'), 'text/csv') }
      
      it "does not create users and shows error message" do # This test fails
        expect {
          post :new_bulk_users, params: { user_bulk: { csv_file: csv_file } }
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_users_bulk_path)
        expect(flash[:error]).to eq('CSV file is invalid.')
      end
    end
  end
end
