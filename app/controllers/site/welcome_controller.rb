class Site::WelcomeController < SiteController
  before_action :redirect_back

  def redirect_back
    if user_signed_in?
      redirect_to users_backoffice_admin_index_path
    end
  end

  def index
  end
end
