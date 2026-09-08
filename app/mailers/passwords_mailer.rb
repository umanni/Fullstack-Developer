class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Set or reset your password", to: user.email
  end
end
