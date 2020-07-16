module Api
  module V1
    class UserImportsController < Api::V1::ApiController
      before_action :authenticate_user, only: %i[create]
      load_and_authorize_resource except: %i[create index]

      
      def create
        @user_import = UserImport.new(user_import_params)
        if @user_import.save
          import_users(@user_import.id)
          render json: {success: 'File uploaded successfully!'}, status: :created             
        else
          render json: {error: @user_import.errors}, status:unprocessable_entity        
        end
      end

      private   

      def import_users(id=0)
        
        if id > 0
          @user = UserImport.find(id)
          file_path = @user.attachment.current_path
                    
          data = Roo::Spreadsheet.open(file_path)
          headers = data.row(1)
          data.each_with_index do |row, idx|
            next if idx == 0

            user_data = Hash[[headers, row].transpose]
            if User.exists?(email: user_data['email'])
              puts "User with email '#{user_data['email']}' already exists"
              next
            end

            user_data['password'] = user_data['password'].to_s
            user = User.new(
              full_name: user_data['full_name'], 
              email: user_data['email'], 
              password_digest: BCrypt::Password.create(user_data['password']),
              role: user_data['role'],
            )
            user.save
          end
        end
      end
    
      def user_import_params   
        params.permit(:name, :attachment, :imported)
      end   
    
    end
  end
end