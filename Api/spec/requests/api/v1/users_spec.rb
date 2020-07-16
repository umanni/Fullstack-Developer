require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Api::V1::Users', type: :request do

  describe 'GET /api/v1/users' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :get, '/api/v1/users'
    end

    context 'Authenticated' do
      let(:user) { create(:user) }

      before do
        get "/api/v1/users", headers: header_with_authentication(user)
      end

      it 'return 200' do
        expect(response).to have_http_status(200)
      end
    end
  end


  describe 'GET /api/v1/users/current' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :get, '/api/v1/users/current'
    end

    context 'Authenticated' do
      let(:user) { create(:user) }

      before do
        get '/api/v1/users/current', headers: header_with_authentication(user)
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns valid user in json' do
        expect(json).to eql(serialized(Api::V1::CurrentUserSerializer, user))
      end
    end
  end


  describe 'DELETE /api/v1/users/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/users/-1'
    end

    context 'Authenticated' do
      context 'User exists' do
        before { @user = create(:user) }

        it 'delete user' do
          expect do
            delete "/api/v1/users/#{@user.id}", headers: header_with_authentication(@user)
          end.to change { User.count }.by(-1)
        end

        it 'delete successfully' do
          delete "/api/v1/users/#{@user.id}", headers: header_with_authentication(@user)
          expect(response).to have_http_status(:no_content)
        end

      end
    end

    context 'User dont exist' do
      let(:user) { create(:user) }
      let(:user_id) { -1 }

      before { delete "/api/v1/users/#{user_id}", headers: header_with_authentication(user) }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  
  describe 'POST /api/v1/users' do
    before do
      @user = create(:user)
    end

    context "With valid params" do
      before do
        @user_attributes = attributes_for(:user)
        post "/api/v1/users", params: {user: @user_attributes}, headers: header_with_authentication(@user)
      end

      it "return created" do
        expect(response).to have_http_status(:created) 
      end

      it 'returns right user in json' do 
        expect(json).to include_json(@user_attributes.except(:password))
      end

      it 'create user' do
        expect{ create(:user) }.to change{User.all.size}.by(1)
      end

      

    end

    context "With invalid params" do 
      let(:user_params) { {foo: :bar} }

      before { post '/api/v1/users/', params: {user: user_params} }

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'PUT /api/v1/users/:id' do
    context "With Invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :put, '/api/v1/users/-1'
    end

    context "With valid authentication headers" do
      before do
        @user = create(:user)
      end

      context "When user exists" do

        context "And user is the user passed in put" do
          before do
            @user = create(:user)
            @user_attributes = attributes_for(:user)
            put "/api/v1/users/#{@user.id}", params: {user: @user_attributes}, headers: header_with_authentication(@user)
          end

          it "return 200" do
            expect(response).to have_http_status(:success) 
          end

          it 'wrong param user to update' do 
            @user_new = create(:user)
            @user_wrong_params  = { email: @user_new.email, password: @user_new.password, new_password: '9787654321'}
            put "/api/v1/users/#{@user.id}", params: {user: @user_wrong_params}, headers: header_with_authentication(@user)
            expect(response).to have_http_status(:unprocessable_entity) 
          end

          it 'empty param user to update' do 
            @user_wrong_params = {}
            put "/api/v1/users/#{@user.id}", params: {user: @user_wrong_params}, headers: header_with_authentication(@user)
            expect(response).to have_http_status(:bad_request) 
          end


          context "change password" do
            before do
              @user_change  = create(:user, full_name: "Tiago", email: "tiago@gmail.com", role: "admin", password: "123456789")
              @user_params  = { email: @user_change.email, password: @user_change.password, new_password: '9787654321'}
            end
              
            it 'with successfully' do
              post "/api/v1/users/password/change", params: @user_params,  headers: header_with_authentication(@user_change)
              expect(response).to have_http_status(:created) 
            end

            it 'with wrong current password' do
              @user_wrong_params = { email: @user_change.email, password: "1223456789", new_password: '9787654321'}
              post "/api/v1/users/password/change", params: @user_wrong_params,  headers: header_with_authentication(@user_change)
              expect(response).to have_http_status(:unprocessable_entity) 
            end

            it 'with user not exist' do
              @user_not_exist = { email: "00012@gmail.com", password: "1223456789", new_password: '9787654321'}
              post "/api/v1/users/password/change", params: @user_not_exist,  headers: header_with_authentication(@user_change)
              expect(response).to have_http_status(:forbidden) 
            end

            it 'email is blank' do
              @user_not_exist = { email: "", password: "1223456789", new_password: '9787654321'}
              post "/api/v1/users/password/change", params: @user_not_exist,  headers: header_with_authentication(@user_change)
              expect(response).to have_http_status(:unprocessable_entity) 
            end

          end

        end

      end

      context "When user dont exists" do
        before do
          @user_attributes = attributes_for(:user)
        end

        it "returns 404" do
          put "/api/v1/users/#{FFaker::Lorem.word}", params: {user: @user_attributes}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end

end