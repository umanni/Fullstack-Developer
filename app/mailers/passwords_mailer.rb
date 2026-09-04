class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user

    in_the_language_of(user) do
      mail subject: t("passwords_mailer.reset.subject"), to: user.email_address
    end
  end
end
