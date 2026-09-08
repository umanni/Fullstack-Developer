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

ActiveRecord::Schema[8.1].define(version: 2026_09_07_161301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_import_rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.jsonb "payload", default: {}, null: false
    t.integer "row_number", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "user_import_id", null: false
    t.index ["user_id"], name: "index_user_import_rows_on_user_id"
    t.index ["user_import_id", "row_number"], name: "index_user_import_rows_on_user_import_id_and_row_number", unique: true
    t.index ["user_import_id", "status"], name: "index_user_import_rows_on_user_import_id_and_status"
    t.index ["user_import_id"], name: "index_user_import_rows_on_user_import_id"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'succeeded'::character varying, 'failed'::character varying]::text[])", name: "user_import_rows_status_check"
  end

  create_table "user_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "failed_rows", default: 0, null: false
    t.text "failure_message"
    t.datetime "finished_at"
    t.integer "processed_rows", default: 0, null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.integer "successful_rows", default: 0, null: false
    t.integer "total_rows", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id", null: false
    t.index ["status"], name: "index_user_imports_on_status"
    t.index ["uploaded_by_id"], name: "index_user_imports_on_uploaded_by_id"
    t.check_constraint "processed_rows = (successful_rows + failed_rows) AND processed_rows <= total_rows", name: "user_imports_consistent_counters_check"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'completed_with_errors'::character varying, 'failed'::character varying]::text[])", name: "user_imports_status_check"
    t.check_constraint "total_rows >= 0 AND processed_rows >= 0 AND successful_rows >= 0 AND failed_rows >= 0", name: "user_imports_non_negative_counters_check"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.check_constraint "role::text = ANY (ARRAY['user'::character varying, 'admin'::character varying]::text[])", name: "users_role_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_import_rows", "user_imports"
  add_foreign_key "user_import_rows", "users", on_delete: :nullify
  add_foreign_key "user_imports", "users", column: "uploaded_by_id"
end
