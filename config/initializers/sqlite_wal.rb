# frozen_string_literal: true

ActiveSupport.on_load(:active_record_sqlite3adapter) do
  prepend(Module.new {
    def configure_connection
      super
      # Switch SQLite to Write-Ahead Logging.
      #
      # Instead of overwriting the main .sqlite3 file on every transaction
      # (the default rollback-journal mode, which blocks readers while writing),
      # SQLite appends changes to a sidecar -wal file. This keeps the main
      # database readable by many concurrent processes (e.g. the parallelized
      # test suite and Workers) while a single writer is active, and only
      # checkpoints back into the main file periodically.
      #
      # raw_connection is the underlying SQLite3::Database exposed by the
      # adapter, used here because Active Record does not expose this pragma.
      # journal_mode is per-database and sticky, but running it on every
      # connection (dev/test/prod, including the cache/queue/cable dbs) makes
      # sure a connection never starts in the slower rollback mode.
      #
      # Paired with busy_timeout from config/database.yml (timeout: 5000),
      # which prevents SQLITE_BUSY errors when processes contend for the
      # single writer slot that WAL allows.
      raw_connection.execute("PRAGMA journal_mode=WAL")
    end
  })
end
