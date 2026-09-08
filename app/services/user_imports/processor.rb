# frozen_string_literal: true

module UserImports
  # Orchestrates the async import (SRP + DIP): each collaborator is injected
  # in the constructor with a real default; tests swap in fakes. The Processor
  # composes — it does not own parser/form/broadcast logic.
  class Processor
    BATCH_SIZE = 25
    # Attribute-level errors that map cleanly onto a spreadsheet cell.
    ATTRIBUTES = %i[full_name email_address avatar_url].freeze

    def initialize(
      parser_class: UserImports::Parser::Roo,
      form_class: Users::RegistrationForm,
      broadcaster: UserImports::ProgressBroadcaster.new,
      dashboard_publisher: Dashboard::Publisher.new
    )
      @parser_class = parser_class
      @form_class = form_class
      @broadcaster = broadcaster
      @dashboard_publisher = dashboard_publisher
    end

    # - parses once (total_rows persisted upfront)
    # - persists each row through a shared Form Object (RegistrationForm +
    #   generated invite password) inside per-batch transactions
    # - counts processed/failed, aggregates row errors into a summary
    # - broadcasts progress after every batch and always writes a final state
    #   (the last broadcast carries the completion/failure status — Phase 6)
    def call(user_import)
      result = parser_class.new.parse(user_import.file)
      user_import.update!(
        status: :processing,
        total_rows: result.total_rows,
        processed_rows: 0,
        failed_rows: 0
      )

      row_errors = []
      result.rows.each_slice(BATCH_SIZE) do |batch|
        process_batch(user_import, batch, row_errors)
        broadcaster.call(user_import)
      end

      finish(user_import, row_errors)
    rescue StandardError => error
      fail_import(user_import, error)
    end

    private

    attr_reader :parser_class, :form_class, :broadcaster, :dashboard_publisher

    def process_batch(user_import, batch, row_errors)
      User.transaction do
        batch.each { |row| process_row(user_import, row, row_errors) }
      end
    end

    def process_row(user_import, row, row_errors)
      invite = generated_password
      form = form_class.new(
        row.attributes.merge(
          password: invite,
          password_confirmation: invite,
          ignore_duplicate_emails: true,
          require_avatar: false
        )
      )

      if form.save
        user_import.increment!(:processed_rows)
      else
        user_import.increment!(:failed_rows)
        row_errors.concat(row_errors(form, row))
      end
    end

    def row_errors(form, row)
      names = form.errors.attribute_names & ATTRIBUTES
      names = form.errors.attribute_names if names.empty?
      names.flat_map do |attribute|
        form.errors.full_messages_for(attribute).map do |message|
          RowError.new(row_number: row.row_number, attribute: attribute, message: message)
        end
      end
    end

    # Any failed row makes the outcome :failed with an aggregated summary
    # (count + row numbers only — never leaked row data).
    def finish(user_import, row_errors)
      user_import.update!(
        status: row_errors.any? ? :failed : :completed,
        error_message: row_errors.any? ? summary(row_errors) : nil,
        finished_at: Time.current
      )
      broadcaster.call(user_import)
      dashboard_publisher.call
    end

    # Fatal errors (parse/IO/DB) also land in a final :failed state — no
    # re-raise, so a broken file is not retried forever by the queue.
    def fail_import(user_import, error)
      warn "===IMPORT ERROR=== #{error.class}: #{error.message}" if ENV["DEBUG_IMPORT_ERROR"] == "1"
      user_import.update!(
        status: :failed,
        error_message: "Could not process the file (#{error.class}).",
        finished_at: Time.current
      )
      broadcaster.call(user_import)
    end

    def summary(row_errors)
      rows = row_errors.map(&:row_number).uniq
      "#{row_errors.size} error(s) in #{rows.size} row(s): #{rows.join(", ")}."
    end

    def generated_password
      SecureRandom.urlsafe_base64(12)
    end
  end
end
