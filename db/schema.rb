# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_04_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_events", force: :cascade do |t|
    t.integer "action", null: false
    t.string "actor_email", null: false
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.string "subject_email", null: false
    t.bigint "subject_id"
    t.index ["action"], name: "index_audit_events_on_action"
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["created_at"], name: "index_audit_events_on_created_at"
    t.index ["subject_id"], name: "index_audit_events_on_subject_id"
    t.check_constraint "action >= 0 AND action <= 5", name: "audit_events_action_within_enum"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_import_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.string "messages", default: [], null: false, array: true
    t.integer "row_number", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_import_id", null: false
    t.index ["user_import_id", "row_number"], name: "index_user_import_errors_on_user_import_id_and_row_number"
    t.index ["user_import_id"], name: "index_user_import_errors_on_user_import_id"
    t.check_constraint "row_number > 0", name: "user_import_errors_row_number_positive"
  end

  create_table "user_imports", force: :cascade do |t|
    t.string "administrator_email", null: false
    t.bigint "administrator_id"
    t.datetime "created_at", null: false
    t.integer "created_users", default: 0, null: false
    t.text "failure_reason"
    t.datetime "finished_at"
    t.integer "processed_rows", default: 0, null: false
    t.integer "rejected_rows", default: 0, null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.integer "total_rows", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_user_imports_on_administrator_id"
    t.index ["created_at"], name: "index_user_imports_on_created_at"
    t.index ["status"], name: "index_user_imports_on_status"
    t.check_constraint "status >= 0 AND status <= 4", name: "user_imports_status_within_enum"
    t.check_constraint "total_rows >= 0 AND processed_rows >= 0 AND created_users >= 0 AND rejected_rows >= 0", name: "user_imports_counters_not_negative"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.string "locale", default: "en", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.virtual "searchable_text", type: :string, as: "(((full_name)::text || ' '::text) || (email_address)::text)", stored: true
    t.datetime "updated_at", null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["searchable_text"], name: "index_users_on_searchable_text_trigrams", opclass: :gin_trgm_ops, using: :gin
    t.check_constraint "locale::text = ANY (ARRAY['en'::character varying, 'pt-BR'::character varying, 'es'::character varying]::text[])", name: "users_locale_supported"
    t.check_constraint "role = ANY (ARRAY[0, 1])", name: "users_role_within_enum"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_events", "users", column: "actor_id", on_delete: :nullify
  add_foreign_key "audit_events", "users", column: "subject_id", on_delete: :nullify
  add_foreign_key "sessions", "users"
  add_foreign_key "user_import_errors", "user_imports"
  add_foreign_key "user_imports", "users", column: "administrator_id"
end
