class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:show]

    def index
        @user = User.all
    end
    
    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def edit
        @user = User.find(params[:id])
    end

    def create
        @user = User.new(user_params)

        if @user.save
            redirect_to @user, alert: { success: 'User was successfully created.' }
        else
            render :action => 'new'
        end
    end

    def update
        @user = User.find(params[:id])

        if @user.update_attributes(user_params)
            sign_in(@user, :bypass => true) if @user == current_user
            redirect_to @user, notice: { success: 'User was successfully updated.' }
        else
            render :action => 'edit'
        end
    end

    def destroy
        @user = User.find(params[:id])
        @user.destroy
        redirect_to users_path, notice: { success: 'User was successfully deleted.' }
    end

    private
        def user_params
            params.require(:user).permit(:full_name, :avatar_image, :email, :password, :password_confirmation, :role, )
        end
end
