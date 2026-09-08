# frozen_string_literal: true

module Users
  # Base form object: single source of user write validations (DRY).
  # Subclasses add use-case rules: RegistrationForm (role :user + password),
  # Admin::UserForm (role + optional password) and ProfileForm (own profile).
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :user
    attr_accessor :avatar

    attribute :full_name, :string
    attribute :email_address, :string
    attribute :avatar_url, :string
    # Import idempotency (Fase 5): when enabled, an already-imported email is
    # a silent no-op instead of a duplicate error. The policy lives here, in
    # the Form — never as a loose `if` in the Processor.
    attribute :ignore_duplicate_emails, :boolean, default: false
    # Import use case (Fase 5): spreadsheets may lack avatar columns, so the
    # avatar rule is relaxed there (placeholder avatar in the presenter).
    # Every interactive write keeps the avatar requirement.
    attribute :require_avatar, :boolean, default: true

    validates :full_name, presence: true, length: { maximum: 100 }
    validate :avatar_source
    validate :avatar_url_format, if: -> { avatar_url.present? }

    def initialize(attributes = {}, user: nil, role: nil)
      @user = user || build_user(role)
      super(attributes)
    end

    def save
      persist
    end

    def update
      persist
    end

    private

    def persist
      return true if skip_existing_email?
      return false unless valid?

      apply_attributes
      return true if user.save

      errors.merge!(user.errors)
      user.avatar.purge if avatar.present?
      false
    end

    # Re-processing the same spreadsheet must not fail: an existing email is
    # counted as processed (a no-op) instead of raising "already taken".
    def skip_existing_email?
      return false unless ignore_duplicate_emails

      existing = User.find_by(email_address: email_address)
      return false unless existing

      @user = existing
      true
    end

    def apply_attributes
      user.assign_attributes(user_attributes)
      apply_avatar
    end

    def user_attributes
      {
        full_name: full_name,
        email_address: email_address
      }
    end

    def build_user(role)
      User.new.tap { |record| record.role = role if role }
    end

    def apply_avatar
      if avatar.present?
        user.avatar.attach(avatar)
        user.avatar_url = nil
      elsif avatar_url.present?
        user.avatar.purge if user.avatar.attached?
        user.avatar_url = avatar_url
      end
    end

    def avatar_source
      return unless require_avatar
      return if avatar.present?
      return if avatar_url.present?
      return if user.persisted? && user.avatar_source.present?

      errors.add(:base, :avatar_required)
    end

    def avatar_url_format
      return if avatar_url.match?(%r{\Ahttps?://}) && avatar_url.length <= 2048

      errors.add(:avatar_url, :invalid_http_url)
    end
  end
end
