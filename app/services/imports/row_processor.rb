module Imports
  class RowProcessor
    ROLE_MAP = {
      "" => "user",
      "user" => "user",
      "no-admin" => "user",
      "no_admin" => "user",
      "false" => "user",
      "0" => "user",
      "admin" => "admin",
      "true" => "admin",
      "1" => "admin"
    }.freeze

    def self.call(import_row, user_creator: Users::Create)
      new(import_row, user_creator:).call
    end

    def initialize(import_row, user_creator:)
      @import_row = import_row
      @user_creator = user_creator
    end

    def call
      role = ROLE_MAP[import_row.payload.fetch("role", "").downcase]
      return fail_row("Role must be admin, user, or no-admin.") unless role

      UserImportRow.transaction do
        user = user_creator.call(
          attributes: import_row.payload.slice("full_name", "email", "avatar_image_url").merge("role" => role),
          invite: true,
          broadcast: false
        )

        if user.persisted?
          import_row.update!(status: :succeeded, user:, error_message: nil)
        else
          fail_row(user.errors.full_messages.to_sentence)
        end
      end

      import_row
    rescue ActiveRecord::RecordNotUnique
      fail_row("Email has already been taken.")
    end

    private
      attr_reader :import_row, :user_creator

      def fail_row(message)
        import_row.update!(status: :failed, user: nil, error_message: message.to_s.truncate(500))
        import_row
      end
  end
end
