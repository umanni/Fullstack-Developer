class LocalesController < ApplicationController
  allow_unauthenticated_access

  # Visitors may switch language too, so authentication is not required. The
  # session still has to be resumed by hand: skipping require_authentication
  # also skips what would otherwise populate Current.user, and without it a
  # signed-in user's choice would never reach their account.
  before_action :resume_session

  # Persists the choice on the account when there is one, and in the session
  # otherwise, so a visitor who picks a language keeps it through sign up.
  def update
    locale = params[:locale].to_s

    unless User::SUPPORTED_LOCALES.include?(locale)
      return redirect_back_or_to(root_path, status: :unprocessable_content,
                                            alert: t("locales.unsupported"))
    end

    session[:locale] = locale
    Current.user&.update!(locale: locale)

    redirect_back_or_to(root_path, status: :see_other)
  end
end
