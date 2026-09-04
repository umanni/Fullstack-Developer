# Sent to people who were created by an import rather than by signing up: the
# account exists, they have never seen a password, and this is how they learn
# both facts.
class InvitationsMailer < ApplicationMailer
  def invite(user)
    @user = user
    @token = user.generate_token_for(:invitation)

    in_the_language_of(user) do
      mail subject: t("invitations_mailer.invite.subject"), to: user.email_address
    end
  end
end
