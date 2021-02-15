class UsersController < Devise::RegistrationsController
  def edit
    @user = User.find(params[:id])
    render :json => @user
  end
end
