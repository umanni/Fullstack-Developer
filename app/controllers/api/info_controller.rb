class Api::InfoController < ApplicationController
  def index
    usersCount = User.count
    adminsCount = User.where(admin: true).count
    notAdminsCount = User.where(admin: false).count

    result = {
      'users' => usersCount,
      'admins' => adminsCount,
      'notAdmins' => notAdminsCount,
    }

    render json: result, status: 200
  end
end
