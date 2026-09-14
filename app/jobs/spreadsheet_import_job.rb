class SpreadsheetImportJob < ApplicationJob
  include ActiveJob::Continuable
  include ActionView::RecordIdentifier

  BROADCAST_EVERY = 10
  DASHBOARD_EVERY = 50
  # Every rejection rewrites the whole JSON column and rides along in the next
  # broadcast, so an all-bad file would grow both without bound. The count keeps
  # counting past this; only the listed reasons stop.
  MAX_ROW_ERRORS = 200

  def perform(spreadsheet_import)
    @import = spreadsheet_import

    step :prepare do
      with_reader { |reader| start_import(reader.row_count) }
    end

    step :import_rows do |step|
      with_reader { |reader| import_rows(reader, step) }
    end

    step :finish do
      persist(status: :completed)
      broadcast_progress
      broadcast_dashboard
    end
  # Continuation::Interrupt is an Exception, so it passes through this rescue.
  rescue StandardError => error
    @import.update(status: :failed, failure_reason: "#{error.class}: #{error.message}".truncate(500))
    broadcast_progress
    broadcast_dashboard
    raise
  end

  private
    def start_import(row_count)
      @import.update!(
        status: :processing, total_rows: row_count,
        processed_rows: 0, failed_rows: 0, row_errors: [], failure_reason: nil
      )
      broadcast_progress
    end

    def import_rows(reader, step)
      @row_errors = @import.row_errors.dup

      # Turbo's refresh debounce restarts on every write, so a bulk job outruns it and
      # broadcasts nothing until it stops. Suppress it and pace the refresh here.
      User.suppressing_turbo_broadcasts do
        reader.each_row do |attributes, line|
          index = line - (SpreadsheetImport::RowReader::HEADER_ROW + 1)
          next if index < step.cursor.to_i

          record_row(attributes, line)
          step.set!(index + 1)
          broadcast_batch(index + 1)
        end
      end

      # No broadcast: :finish sends one straight after, and two a millisecond apart can
      # arrive out of order, leaving the page stuck on "Processing".
      persist
    end

    def broadcast_batch(processed)
      if (processed % BROADCAST_EVERY).zero?
        persist
        broadcast_progress
      end

      broadcast_dashboard if (processed % DASHBOARD_EVERY).zero?
    end

    def record_row(attributes, line)
      # A placeholder nobody authenticates with, replaced at the first password reset.
      # The default cost buys nothing against 140 bits of entropy and costs 250ms a row.
      user = User.new(attributes.merge(password_digest: placeholder_digest))
      user.role = :user unless User.roles.key?(attributes[:role])

      if user.save
        SpreadsheetImport.update_counters(@import.id, processed_rows: 1)
      else
        reject_row(line, user.errors.full_messages.to_sentence)
      end
    rescue ActiveRecord::RecordNotUnique
      # Validation checks uniqueness, then another writer wins the race to the index.
      reject_row(line, "Email has already been taken")
    end

    def placeholder_digest
      BCrypt::Password.create(SecureRandom.base58(24), cost: BCrypt::Engine::MIN_COST)
    end

    def reject_row(line, message)
      SpreadsheetImport.update_counters(@import.id, processed_rows: 1, failed_rows: 1)
      return if @row_errors.size >= MAX_ROW_ERRORS

      @row_errors << { "line" => line, "message" => message }
      # An interruption before the next batch would take the reason with it.
      persist
    end

    def persist(status: nil)
      @import.reload
      @import.update!({ row_errors: @row_errors || @import.row_errors, status: status }.compact)
    end

    def with_reader
      @import.file.open do |file|
        yield SpreadsheetImport::RowReader.new(file.path, extension: file_extension)
      end
    end

    def file_extension
      @import.file.filename.extension_without_delimiter.downcase
    end

    def broadcast_dashboard
      Turbo::StreamsChannel.broadcast_refresh_to(User::DASHBOARD_STREAM)
    end

    def broadcast_progress
      @import.broadcast_replace_to(
        @import,
        target: dom_id(@import, :progress),
        partial: "admin/spreadsheet_imports/progress",
        locals: { spreadsheet_import: @import }
      )
    end
end
