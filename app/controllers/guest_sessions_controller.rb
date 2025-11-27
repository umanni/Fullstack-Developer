class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    guest_email = "guest_#{SecureRandom.hex(8)}@guest.temp"
    guest_user = User.create!(
      email: guest_email,
      full_name: "Usuário Visitante",
      password: SecureRandom.hex(16),
      role: :user
    )

    sign_in(guest_user)
    redirect_to profile_path, notice: 'Você entrou como visitante. Sua conta será temporária.'
  end
end

