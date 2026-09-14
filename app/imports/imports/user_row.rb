module Imports
  class UserRow
    include ActiveModel::Model
    include ActiveModel::Attributes

    HEADER_ALIASES = {
      "full_name" => :full_name, "name" => :full_name, "fullname" => :full_name, "nome" => :full_name,
      "email" => :email_address, "email_address" => :email_address, "e_mail" => :email_address,
      "role" => :role, "perfil" => :role,
      "avatar" => :avatar_url, "avatar_url" => :avatar_url, "photo" => :avatar_url
    }.freeze

    attribute :full_name,     :string
    attribute :email_address, :string
    attribute :role,          :string, default: "member"
    attribute :avatar_url,    :string

    validates :full_name, presence: true, length: { in: 2..120 }
    validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, inclusion: { in: User.roles.keys, message: "must be admin or member" }
    validates :avatar_url, format: { with: %r{\Ahttps://\S+\z} }, allow_blank: true

    def self.normalize_headers(headers)
      headers.map do |header|
        key = header.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").delete_prefix("_").delete_suffix("_")
        HEADER_ALIASES[key]
      end
    end

    def self.from(headers, values)
      attributes = headers.zip(values).to_h.compact.except(nil)
      new(attributes.transform_values { sanitize(_1) })
    end

    def self.sanitize(value)
      text = value.is_a?(String) ? value : value.to_s
      # Strip leading =, +, -, @ so a cell like "=cmd|..." cannot become a live
      # formula if this data is ever re-exported to a spreadsheet.
      text.squish.sub(/\A[=+\-@\t\r]+/, "")
    end

    def normalized_email = email_address.to_s.strip.downcase

    def to_user_attributes
      { full_name:, email_address: normalized_email, role:, avatar_url: avatar_url.presence,
        password: SecureRandom.base58(24) }
    end
  end
end
