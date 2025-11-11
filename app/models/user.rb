require 'open-uri'

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_one_attached :avatar

  attr_accessor :avatar_url

  enum role: { user: 0, admin: 1 }

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :avatar_validation

  before_validation :attach_avatar_from_url, if: -> { avatar_url.present? && avatar.blank? }

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= :user
  end

  def avatar_validation
    return unless avatar.attached?

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, 'is too large (max 5MB)')
    end

    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, 'must be a JPEG, PNG, or GIF')
    end
  end

  def attach_avatar_from_url
    begin
      file = URI.open(avatar_url)
      filename = File.basename(URI.parse(avatar_url).path.presence || 'avatar.png')
      content_type = file.respond_to?(:content_type) ? file.content_type : 'image/png'

      avatar.attach(io: file, filename: filename, content_type: content_type)
    rescue StandardError
      errors.add(:avatar_url, 'não pôde ser carregado')
      throw(:abort)
    end
  end
end