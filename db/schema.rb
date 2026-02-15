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

ActiveRecord::Schema[8.1].define(version: 2026_02_15_022749) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "author", null: false
    t.integer "available_copies", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "genre", null: false
    t.string "isbn", null: false
    t.string "title", null: false
    t.integer "total_copies", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.check_constraint "available_copies <= total_copies", name: "books_available_within_total"
    t.check_constraint "available_copies >= 0", name: "books_available_copies_non_negative"
    t.check_constraint "total_copies >= 0", name: "books_total_copies_non_negative"
  end

  create_table "borrowings", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "borrowed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "due_at", null: false
    t.datetime "returned_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_borrowings_on_book_id"
    t.index ["due_at"], name: "index_borrowings_on_due_at"
    t.index ["returned_at"], name: "index_borrowings_on_returned_at"
    t.index ["user_id", "book_id"], name: "index_borrowings_on_user_and_book_when_active", unique: true, where: "(returned_at IS NULL)"
    t.index ["user_id"], name: "index_borrowings_on_user_id"
    t.check_constraint "due_at > borrowed_at", name: "borrowings_due_after_borrowed"
    t.check_constraint "returned_at IS NULL OR returned_at >= borrowed_at", name: "borrowings_returned_after_borrowed"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index [ "jti" ], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index [ "reset_password_token" ], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "email::text = lower(email::text) AND email::text = btrim(email::text)", name: "users_email_canonical"
    t.check_constraint "role::text = ANY (ARRAY['librarian'::character varying::text, 'member'::character varying::text])", name: "users_role_allowed_values"
  end

  add_foreign_key "borrowings", "books"
  add_foreign_key "borrowings", "users"
end
