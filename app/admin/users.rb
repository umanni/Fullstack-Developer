ActiveAdmin.register User do

  # Permit Params
  permit_params do
    permitted = [:full_name, :email, :role, :password, :password_confirmation]
    permitted << :other if params[:action] == 'create' && current_user.role?
    permitted
  end

  # Edit User detais
  

  # Edit create form
  form do |f|
    f.inputs "User" do
      f.input :full_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, label: "Admin ?"
    end
    f.actions
  end

  # Edit view
  index do
    selectable_column
    column :id
    column :full_name
    column :email
    column "Admin ?", :role
    actions
  end

  # Custom filters
  filter :id
  filter :full_name
  filter :email
  filter :role, label: "Admin ?"

  # Import Spreadsheet
  # active_admin_import

  active_admin_import :validate => false,
                        :before_batch_import => proc { |import|
                          import.csv_lines[0][2] = User.new(:password => import.csv_lines[0][2]).encrypted_password
                        },
                        :template_object => ActiveAdminImport::Model.new(
                            :hint => "file will be imported with such header format: 'full_name','email','encrypted_password'"
                        ),
                        :timestamps=> true,
                        :batch_size => 1000

end
