module Imports
  class UserImporter
    Result = Data.define(:outcome, :errors) do
      def created? = outcome == :created
      def skipped? = outcome == :skipped
      def failed?  = outcome == :failed
    end

    def call(row)
      return Result.new(outcome: :failed, errors: row.errors.full_messages) if row.invalid?

      user = User.find_or_initialize_by(email_address: row.normalized_email)
      return Result.new(outcome: :skipped, errors: []) if user.persisted?

      user.assign_attributes(row.to_user_attributes)

      if user.save
        Result.new(outcome: :created, errors: [])
      else
        Result.new(outcome: :failed, errors: user.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique
      # Lost a race with a concurrent import or signup on the unique index.
      Result.new(outcome: :skipped, errors: [])
    end
  end
end
