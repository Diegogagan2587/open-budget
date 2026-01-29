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

ActiveRecord::Schema[8.0].define(version: 2026_01_29_203647) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["user_id", "account_id"], name: "index_account_memberships_on_user_id_and_account_id", unique: true
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_line_items", force: :cascade do |t|
    t.bigint "budget_period_id", null: false
    t.bigint "category_id", null: false
    t.string "description"
    t.decimal "planned_amount", precision: 10, scale: 2
    t.float "percentage_of_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_budget_line_items_on_account_id"
    t.index ["budget_period_id"], name: "index_budget_line_items_on_budget_period_id"
    t.index ["category_id"], name: "index_budget_line_items_on_category_id"
  end

  create_table "budget_periods", force: :cascade do |t|
    t.string "name"
    t.string "period_type"
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_budget_periods_on_account_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "expense_templates", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "category_id", null: false
    t.string "description"
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.string "frequency", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_expense_templates_on_account_id"
    t.index ["category_id"], name: "index_expense_templates_on_category_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.date "date"
    t.decimal "amount", precision: 10, scale: 2
    t.string "description"
    t.bigint "category_id", null: false
    t.bigint "budget_period_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "income_event_id"
    t.bigint "planned_expense_id"
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_expenses_on_account_id"
    t.index ["budget_period_id"], name: "index_expenses_on_budget_period_id"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["income_event_id"], name: "index_expenses_on_income_event_id"
    t.index ["planned_expense_id"], name: "index_expenses_on_planned_expense_id"
  end

  create_table "income_events", force: :cascade do |t|
    t.bigint "budget_period_id"
    t.date "expected_date", null: false
    t.decimal "expected_amount", precision: 10, scale: 2, null: false
    t.date "received_date"
    t.decimal "received_amount", precision: 10, scale: 2
    t.string "description", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_income_events_on_account_id"
    t.index ["budget_period_id"], name: "index_income_events_on_budget_period_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "stock_state", default: "in_stock", null: false
    t.boolean "consumable", default: true, null: false
    t.bigint "category_id"
    t.text "notes"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_inventory_items_on_account_id"
    t.index ["category_id"], name: "index_inventory_items_on_category_id"
    t.index ["consumable"], name: "index_inventory_items_on_consumable"
    t.index ["stock_state"], name: "index_inventory_items_on_stock_state"
  end

  create_table "planned_expenses", force: :cascade do |t|
    t.bigint "income_event_id", null: false
    t.bigint "category_id", null: false
    t.bigint "expense_template_id"
    t.string "description", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "notes"
    t.string "status", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.bigint "shopping_item_id"
    t.index ["account_id"], name: "index_planned_expenses_on_account_id"
    t.index ["category_id"], name: "index_planned_expenses_on_category_id"
    t.index ["expense_template_id"], name: "index_planned_expenses_on_expense_template_id"
    t.index ["income_event_id"], name: "index_planned_expenses_on_income_event_id"
    t.index ["shopping_item_id"], name: "index_planned_expenses_on_shopping_item_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shopping_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.string "item_type", default: "one_time", null: false
    t.string "quantity"
    t.decimal "estimated_amount", precision: 10, scale: 2
    t.bigint "category_id"
    t.bigint "planned_expense_id"
    t.bigint "expense_id"
    t.string "frequency"
    t.date "last_purchased_at"
    t.text "notes"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_shopping_items_on_account_id"
    t.index ["category_id"], name: "index_shopping_items_on_category_id"
    t.index ["expense_id"], name: "index_shopping_items_on_expense_id"
    t.index ["item_type"], name: "index_shopping_items_on_item_type"
    t.index ["planned_expense_id"], name: "index_shopping_items_on_planned_expense_id"
    t.index ["status"], name: "index_shopping_items_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "locale", default: "en"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "budget_line_items", "accounts"
  add_foreign_key "budget_line_items", "budget_periods"
  add_foreign_key "budget_line_items", "categories"
  add_foreign_key "budget_periods", "accounts"
  add_foreign_key "categories", "accounts"
  add_foreign_key "expense_templates", "accounts"
  add_foreign_key "expense_templates", "categories"
  add_foreign_key "expenses", "accounts"
  add_foreign_key "expenses", "budget_periods"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "income_events"
  add_foreign_key "expenses", "planned_expenses"
  add_foreign_key "income_events", "accounts"
  add_foreign_key "income_events", "budget_periods"
  add_foreign_key "inventory_items", "accounts"
  add_foreign_key "inventory_items", "categories"
  add_foreign_key "planned_expenses", "accounts"
  add_foreign_key "planned_expenses", "categories"
  add_foreign_key "planned_expenses", "expense_templates"
  add_foreign_key "planned_expenses", "income_events"
  add_foreign_key "planned_expenses", "shopping_items"
  add_foreign_key "sessions", "users"
  add_foreign_key "shopping_items", "accounts"
  add_foreign_key "shopping_items", "categories"
  add_foreign_key "shopping_items", "expenses"
  add_foreign_key "shopping_items", "planned_expenses"
end
