module Api
  module V1
    class CurrentUserSerializer < ActiveModel::Serializer # >
      attributes :id, :full_name, :avatar_image, :email, :admin

      def avatar_image
        object.avatar_image ? object.avatar_image.profile.url : ''
      end

      def admin
        object.role === "admin" ? true : false
      end
    end
  end
end