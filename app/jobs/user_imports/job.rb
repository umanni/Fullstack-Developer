# frozen_string_literal: true

module UserImports
  # Thin job: only sets the processing state and delegates to the service.
  # No business rule lives here (SRP).
  class Job < ApplicationJob
    queue_as :imports

    def perform(user_import)
      user_import.update!(status: :processing) unless user_import.processing?
      UserImports::Processor.new.call(user_import)
    end
  end
end
