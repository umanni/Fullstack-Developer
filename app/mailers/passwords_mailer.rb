class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset your Umanni Users password", to: user.email
  end

  def invitation(user)
    @user = user
    mail subject: "Set up your Umanni Users account", to: user.email
  end
end
