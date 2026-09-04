module Admin
  class UsersController < BaseController
    include Pagy::Backend

    before_action :set_user, only: %i[edit update destroy]

    def index
      @role_counts = User.role_counts
      @pagy, @users = pagy(filtered_users, limit: per_page)
    end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: t(".created", name: @user.full_name)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: t(".updated", name: @user.full_name)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @user.destroy
        redirect_to admin_users_path, notice: t(".deleted", name: @user.full_name), status: :see_other
      else
        redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence, status: :see_other
      end
    end

    private

    def set_user
      @user = User.find(params.expect(:id))
    end

    # Unlike the public form, an administrator may set the role. The last
    # administrator is still protected -- by the model, not by this list.
    def user_params
      permitted = params.expect(user: %i[full_name email_address avatar_url avatar role password])
      # An empty password field on the edit form means "leave it alone", not
      # "set the password to nothing".
      permitted.delete(:password) if permitted[:password].blank?
      permitted
    end

    # The avatar of every row is rendered, so the attachment, its blob and the
    # variant record are loaded with the page rather than one query per person.
    def filtered_users
      User.search(params[:query])
          .with_role(params[:role])
          .ordered
          .includes(avatar_attachment: { blob: :variant_records })
    end

    # Bounded so a hand-edited URL cannot ask for the whole table at once.
    def per_page
      requested = params[:per_page].to_i
      return Pagy::DEFAULT[:limit] if requested <= 0

      requested.clamp(1, 100)
    end
  end
end
