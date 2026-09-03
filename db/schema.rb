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

ActiveRecord::Schema[8.1].define(version: 2026_09_02_231500) do
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
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "user_import_id", null: false
    t.index ["user_id"], name: "index_user_import_rows_on_user_id"
    t.index ["user_import_id", "row_number"], name: "index_user_import_rows_on_user_import_id_and_row_number", unique: true
    t.index ["user_import_id"], name: "index_user_import_rows_on_user_import_id"
    t.check_constraint "row_number >= 2", name: "user_import_rows_row_number_check"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "user_import_rows_status_check"
  end

  create_table "user_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "failed_rows", default: 0, null: false
    t.text "failure_message"
    t.datetime "finished_at"
    t.integer "processed_rows", default: 0, null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.integer "succeeded_rows", default: 0, null: false
    t.integer "total_rows", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_user_imports_on_created_by_id"
    t.check_constraint "(succeeded_rows + failed_rows) = processed_rows", name: "user_imports_processed_breakdown_check"
    t.check_constraint "processed_rows <= total_rows", name: "user_imports_processed_within_total_check"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2, 3, 4])", name: "user_imports_status_check"
    t.check_constraint "total_rows >= 0 AND processed_rows >= 0 AND succeeded_rows >= 0 AND failed_rows >= 0", name: "user_imports_counters_non_negative_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_image_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.check_constraint "char_length(email::text) <= 254", name: "users_email_length_check"
    t.check_constraint "char_length(full_name::text) >= 2 AND char_length(full_name::text) <= 100", name: "users_full_name_length_check"
    t.check_constraint "role = ANY (ARRAY[0, 1])", name: "users_role_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_import_rows", "user_imports"
  add_foreign_key "user_import_rows", "users", on_delete: :nullify
  add_foreign_key "user_imports", "users", column: "created_by_id", on_delete: :nullify
end
