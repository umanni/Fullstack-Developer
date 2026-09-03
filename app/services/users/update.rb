module Users
  class Update
    def self.call(user:, attributes:)
      new(user:, attributes: attributes.to_h.symbolize_keys).call
    end

    def initialize(user:, attributes:)
      @user = user
      @attributes = attributes
    end

    def call
      uploaded_avatar = attributes.delete(:avatar_image)
      replace_attachment_with_url = uploaded_avatar.blank? && attributes[:avatar_image_url].present? && user.avatar_image.attached?

      user.assign_attributes(attributes)
      user.avatar_image.attach(uploaded_avatar) if uploaded_avatar.present?
      user.avatar_image_url = nil if uploaded_avatar.present?

      user.avatar_image.purge_later if user.save && replace_attachment_with_url
      user
    end

    private
      attr_reader :user, :attributes
  end
end
