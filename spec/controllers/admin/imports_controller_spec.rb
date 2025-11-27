require 'rails_helper'

RSpec.describe Admin::ImportsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all imports' do
      import1 = create(:user_import, user: admin)
      import2 = create(:user_import, user: admin)
      get :index
      expect(assigns(:imports)).to include(import1, import2)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new import' do
      get :new
      expect(assigns(:import)).to be_a_new(UserImport)
    end
  end

  describe 'POST #create' do
    let(:csv_content) { "full_name,email,role\nJohn Doe,john@example.com,user" }
    let(:spreadsheet_file) do
      Rack::Test::UploadedFile.new(
        StringIO.new(csv_content),
        'text/csv',
        original_filename: 'test.csv'
      )
    end

    context 'with valid params' do
      it 'creates a new import' do
        expect {
          post :create, params: { user_import: { spreadsheet_file: spreadsheet_file } }
        }.to change(UserImport, :count).by(1)
      end

      it 'enqueues UserImportJob' do
        expect {
          post :create, params: { user_import: { spreadsheet_file: spreadsheet_file } }
        }.to have_enqueued_job(UserImportJob)
      end

      it 'redirects to import show' do
        post :create, params: { user_import: { spreadsheet_file: spreadsheet_file } }
        import = UserImport.last
        expect(response).to redirect_to(admin_import_path(import))
      end

      it 'shows success notice' do
        post :create, params: { user_import: { spreadsheet_file: spreadsheet_file } }
        expect(flash[:notice]).to eq('Import started. Progress will be shown below.')
      end

      it 'associates import with current user' do
        post :create, params: { user_import: { spreadsheet_file: spreadsheet_file } }
        import = UserImport.last
        expect(import.user).to eq(admin)
      end
    end

    context 'with invalid params' do
      it 'does not create import without file' do
        expect {
          post :create, params: { user_import: { spreadsheet_file: nil } }
        }.not_to change(UserImport, :count)
      end

      it 'renders new template' do
        post :create, params: { user_import: { spreadsheet_file: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #show' do
    let(:import) { create(:user_import, user: admin) }

    it 'returns a successful response' do
      get :show, params: { id: import.id }
      expect(response).to be_successful
    end

    it 'assigns the import' do
      get :show, params: { id: import.id }
      expect(assigns(:import)).to eq(import)
    end
  end

  describe 'GET #status' do
    let(:import) { create(:user_import, :processing, user: admin, total_rows: 10, processed_rows: 5, success_count: 4, error_count: 1) }

    it 'returns JSON with import status' do
      get :status, params: { id: import.id }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq('processing')
      expect(json_response['progress']).to be_present
    end

    it 'returns all import data' do
      get :status, params: { id: import.id }
      json_response = JSON.parse(response.body)
      expect(json_response['processed_rows']).to eq(5)
      expect(json_response['total_rows']).to eq(10)
      expect(json_response['success_count']).to eq(4)
      expect(json_response['error_count']).to eq(1)
      expect(json_response['errors']).to be_an(Array)
    end

    it 'authorizes the import' do
      expect(controller).to receive(:authorize).with(import)
      get :status, params: { id: import.id }
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      before do
        sign_in regular_user
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      it 'denies access to index' do
        get :index
        expect(response).not_to be_successful
      end

      it 'denies access to new' do
        get :new
        expect(response).not_to be_successful
      end

      it 'denies access to show' do
        import = create(:user_import, user: admin)
        get :show, params: { id: import.id }
        expect(response).not_to be_successful
      end

      it 'denies access to status' do
        import = create(:user_import, user: admin)
        get :status, params: { id: import.id }
        expect(response).not_to be_successful
      end
    end
  end
end

