module Api
  module V1
    class UserSerializer < ActiveModel::Serializer # >
      attributes :id, :full_name, :avatar_image, :email, :role, :users_count, :users_count_group
 
      def users_count
        @user = User.includes(:user).all.count
      end

      def users_count_group
        @user = User.includes(:user).group(:role).count
      end
 
    end
  end
end