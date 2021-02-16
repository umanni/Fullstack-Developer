class Api::InfoController < ApplicationController
  def index
    usersCount = User.count
    adminsCount = User.where(admin: true).count

    result = {
      'users' => usersCount,
      'admins' => adminsCount
    }
    render json: result, status: 200
  end
end
