class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Redefinição de senha", to: user.email
  end

  def welcome(user)
    @user = user
    mail subject: "Defina sua senha", to: user.email
  end
end
