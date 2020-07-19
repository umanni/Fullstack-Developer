class Admin::UserBulksController < ApplicationController
  # GET /user_bulks
  def index
    @user_bulks = UserBulk.all.paginate(page: params[:page])
  end

  # GET /user_bulks/new
  def new
    @user_bulk = UserBulk.new
  end

  # POST /user_bulks
  def create
    @user_bulk = UserBulk.new(user_bulk_params)
    if @user_bulk.save
      redirect_to admin_user_bulks_path, notice: 'User bulk was successfully created.'
    else
      render :new
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def user_bulk_params
      params.require(:user_bulk).permit(:file)
    end
end
