# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090908054015) do

  create_table "activity_sectors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "activated",  :default => true
  end

  create_table "addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.integer  "has_address_id",   :limit => 11
    t.string   "has_address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country_name"
    t.string   "city_name"
    t.string   "zip_code"
  end

  create_table "alarms", :force => true do |t|
    t.integer  "event_id",        :limit => 11
    t.string   "action"
    t.text     "description"
    t.integer  "do_alarm_before", :limit => 11
    t.integer  "duration",        :limit => 11
    t.string   "title"
    t.string   "email_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_objects", :force => true do |t|
    t.string "name"
  end

  create_table "calendars", :force => true do |t|
    t.integer  "user_id",    :limit => 11
    t.string   "name"
    t.string   "color"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "commodity_category_id",  :limit => 11
    t.integer  "consumable_category_id", :limit => 11
    t.integer  "unit_measure_id",        :limit => 11
    t.integer  "commodities_count",      :limit => 11, :default => 0
    t.integer  "consumables_count",      :limit => 11, :default => 0
    t.boolean  "enable",                               :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_options", :force => true do |t|
    t.string   "name"
    t.integer  "checklist_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_responses", :force => true do |t|
    t.integer  "checklist_id",                :limit => 11
    t.integer  "has_checklist_response_id",   :limit => 11
    t.string   "has_checklist_response_type"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklists", :force => true do |t|
    t.string   "name"
    t.integer  "step_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklists_order_types", :force => true do |t|
    t.integer  "checklist_id",  :limit => 11
    t.integer  "order_type_id", :limit => 11
    t.boolean  "activated",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string  "name"
    t.string  "zip_code"
    t.integer "country_id", :limit => 11
  end

  create_table "civilities", :force => true do |t|
    t.string "name"
  end

  create_table "commodity_categories", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "commodity_category_id", :limit => 11
    t.integer  "unit_measure_id",       :limit => 11
    t.integer  "commodities_count",     :limit => 11, :default => 0
    t.boolean  "enable",                              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.string   "description"
  end

  create_table "consumable_categories", :force => true do |t|
    t.string   "name"
    t.integer  "consumable_category_id", :limit => 11
    t.integer  "unit_measure_id",        :limit => 11
    t.integer  "consumables_count",      :limit => 11, :default => 0
    t.boolean  "enable",                               :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_numbers", :force => true do |t|
    t.string   "category"
    t.string   "indicatif"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_types", :force => true do |t|
    t.string   "name"
    t.string   "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_type_id", :limit => 11
    t.string   "job"
    t.string   "email"
  end

  create_table "contacts_owners", :id => false, :force => true do |t|
    t.integer "contact_id",       :limit => 11
    t.integer "has_contact_id",   :limit => 11
    t.string  "has_contact_type"
    t.integer "contact_type_id",  :limit => 11
  end

  create_table "content_versions", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.integer  "menu_id",        :limit => 11
    t.integer  "content_id",     :limit => 11
    t.datetime "versioned_at"
    t.integer  "contributor_id", :limit => 11
  end

  create_table "contents", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.integer  "menu_id",      :limit => 11
    t.string   "contributors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :limit => 11, :default => 0, :null => false
    t.integer  "author_id",    :limit => 11
  end

  create_table "countries", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "document_types", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_types_mime_types", :id => false, :force => true do |t|
    t.integer "document_type_id", :limit => 11
    t.integer "mime_type_id",     :limit => 11
  end

  create_table "documents", :force => true do |t|
    t.string   "description"
    t.integer  "has_document_id",         :limit => 11
    t.string   "has_document_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.integer  "document_type_id",        :limit => 11
  end

  create_table "employee_states", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  create_table "employees", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "qualification"
    t.date     "birth_date"
    t.string   "email"
    t.string   "society_email"
    t.string   "social_security_number"
    t.integer  "civility_id",            :limit => 11
    t.integer  "family_situation_id",    :limit => 11
    t.integer  "user_id",                :limit => 11
  end

  create_table "employees_jobs", :id => false, :force => true do |t|
    t.integer  "job_id",      :limit => 11
    t.integer  "employee_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees_services", :force => true do |t|
    t.integer  "employee_id", :limit => 11
    t.integer  "service_id",  :limit => 11
    t.boolean  "responsable",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "establishment_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "establishments", :force => true do |t|
    t.string   "name"
    t.integer  "establishment_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id",           :limit => 11
    t.boolean  "activated",                           :default => true
  end

  create_table "estimates", :force => true do |t|
    t.integer  "step_estimate_id", :limit => 11
    t.boolean  "validated",                      :default => false
    t.date     "validity_date"
    t.float    "carriage_costs",                 :default => 0.0
    t.float    "reduction",                      :default => 0.0
    t.float    "account",                        :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimates_product_references", :force => true do |t|
    t.integer  "estimate_id",          :limit => 11
    t.integer  "product_reference_id", :limit => 11
    t.text     "description"
    t.integer  "quantity",             :limit => 11
    t.float    "unit_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_categories", :force => true do |t|
    t.integer "calendar_id", :limit => 11
    t.string  "name"
  end

  create_table "events", :force => true do |t|
    t.integer  "calendar_id",       :limit => 11
    t.integer  "event_category_id", :limit => 11
    t.string   "title"
    t.string   "color"
    t.string   "frequence"
    t.string   "status"
    t.boolean  "full_day",                        :default => false, :null => false
    t.text     "location"
    t.text     "description"
    t.text     "link"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "organizer_id",      :limit => 11
    t.date     "until_date"
    t.integer  "interval",          :limit => 11, :default => 1,     :null => false
    t.integer  "count",             :limit => 11
    t.string   "by_day"
    t.string   "by_month_day"
    t.string   "by_month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exception_dates", :force => true do |t|
    t.integer "event_id", :limit => 11
    t.date    "date"
  end

  create_table "family_situations", :force => true do |t|
    t.string "name"
  end

  create_table "features", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.text     "dependencies"
    t.text     "conflicts"
    t.boolean  "installed",    :default => false, :null => false
    t.boolean  "activated",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "search"
    t.string   "title"
  end

  create_table "file_types", :force => true do |t|
    t.string   "name"
    t.string   "model_owner"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_types_mime_types", :id => false, :force => true do |t|
    t.integer  "file_type_id", :limit => 11
    t.integer  "mime_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ibans", :force => true do |t|
    t.string   "account_name"
    t.integer  "has_iban_id",    :limit => 11
    t.string   "has_iban_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bank_name"
    t.string   "bank_code"
    t.string   "branch_code"
    t.string   "account_number"
    t.string   "key"
  end

  create_table "indicatives", :force => true do |t|
    t.string   "indicative"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id", :limit => 11
  end

  create_table "job_contract_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "limited"
  end

  create_table "job_contracts", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "employee_id",          :limit => 11
    t.integer  "employee_state_id",    :limit => 11
    t.integer  "job_contract_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "departure"
  end

  create_table "jobs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "mission"
    t.text     "activity"
    t.text     "goal"
  end

  create_table "legal_forms", :force => true do |t|
    t.string   "name"
    t.integer  "third_type_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memorandums", :force => true do |t|
    t.string   "title"
    t.string   "subject"
    t.string   "signature"
    t.integer  "user_id",      :limit => 11
    t.text     "text"
    t.datetime "published_at"
    t.datetime "updated_at"
  end

  create_table "memorandums_services", :force => true do |t|
    t.integer  "service_id",    :limit => 11
    t.integer  "memorandum_id", :limit => 11
    t.boolean  "recursive",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "name"
    t.integer  "position",    :limit => 11
    t.integer  "parent_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feature_id",  :limit => 11
    t.boolean  "hidden"
  end

  create_table "mime_type_extensions", :force => true do |t|
    t.string "name"
    t.string "mime_type_id"
  end

  create_table "mime_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "missing_elements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "orders_steps_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "number_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "numbers", :force => true do |t|
    t.string   "number"
    t.integer  "indicative_id",   :limit => 11
    t.integer  "number_type_id",  :limit => 11
    t.integer  "has_number_id",   :limit => 11
    t.string   "has_number_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",                       :default => true
  end

  create_table "order_logs", :force => true do |t|
    t.string   "controller"
    t.string   "action"
    t.integer  "order_id",   :limit => 11
    t.integer  "user_id",    :limit => 11
    t.text     "parameters"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_types_society_activity_sectors", :id => false, :force => true do |t|
    t.integer "society_activity_sector_id", :limit => 11
    t.integer "order_type_id",              :limit => 11
  end

  create_table "orders", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "commercial_id",        :limit => 11
    t.integer  "user_id",              :limit => 11
    t.integer  "customer_id",          :limit => 11
    t.integer  "establishment_id",     :limit => 11
    t.integer  "activity_sector_id",   :limit => 11
    t.integer  "order_type_id",        :limit => 11
    t.datetime "closed_date"
    t.datetime "previsional_start"
    t.datetime "previsional_delivery"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.integer  "event_id",    :limit => 11
    t.text     "name"
    t.string   "email"
    t.integer  "employee_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_time_limits", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_methods", :force => true do |t|
    t.string "name"
    t.string "title"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",              :limit => 11
    t.string   "has_permissions_type"
    t.integer  "has_permissions_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_permission_methods", :force => true do |t|
    t.integer  "permission_id",        :limit => 11
    t.integer  "permission_method_id", :limit => 11
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "premia", :force => true do |t|
    t.date     "date"
    t.text     "remark"
    t.integer  "employee_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",                    :precision => 65, :scale => 30
  end

  create_table "press_proofs", :force => true do |t|
    t.string   "status"
    t.string   "transmission_mode"
    t.integer  "step_graphic_conception_id", :limit => 11
    t.datetime "created_at"
  end

  create_table "product_reference_categories", :force => true do |t|
    t.string   "name"
    t.integer  "product_reference_category_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_references_count",      :limit => 11, :default => 0
    t.boolean  "enable",                                      :default => true
  end

  create_table "product_references", :force => true do |t|
    t.string   "name"
    t.string   "production_cost_manpower"
    t.string   "production_time"
    t.string   "delivery_cost_manpower"
    t.string   "delivery_time"
    t.string   "information"
    t.integer  "product_reference_category_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "products_count",                :limit => 11, :default => 0
    t.boolean  "enable",                                      :default => true
    t.text     "description"
    t.string   "reference"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "production_cost_manpower"
    t.string   "production_time"
    t.string   "delivery_cost_manpower"
    t.string   "delivery_time"
    t.string   "information"
    t.integer  "product_reference_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remarks", :force => true do |t|
    t.text     "text"
    t.integer  "user_id",         :limit => 11
    t.integer  "has_remark_id",   :limit => 11
    t.string   "has_remark_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :limit => 11
    t.integer "user_id", :limit => 11
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "salaries", :force => true do |t|
    t.integer  "job_contract_id", :limit => 11
    t.datetime "created_at"
    t.float    "gross_amount"
  end

  create_table "sales_processes", :force => true do |t|
    t.integer  "order_type_id",      :limit => 11
    t.integer  "step_id",            :limit => 11
    t.boolean  "activated",                        :default => true
    t.boolean  "depending_previous",               :default => false
    t.boolean  "required",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_processes_steps", :force => true do |t|
    t.integer "sales_process_id", :limit => 11
    t.integer "step_id",          :limit => 11
  end

  create_table "schedules", :force => true do |t|
    t.float    "morning_start"
    t.float    "morning_end"
    t.float    "afternoon_start"
    t.float    "afternoon_end"
    t.string   "day"
    t.integer  "service_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.integer  "service_parent_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "society_activity_sectors", :force => true do |t|
    t.string   "name"
    t.boolean  "activated",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_commercials", :force => true do |t|
    t.integer  "order_id",   :limit => 11
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_dependencies", :id => false, :force => true do |t|
    t.integer  "step_id",        :limit => 11
    t.integer  "step_dependent", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_estimates", :force => true do |t|
    t.integer  "step_commercial_id", :limit => 11
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_graphic_conceptions", :force => true do |t|
    t.integer  "step_commercial_id", :limit => 11
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "step_invoicings", :force => true do |t|
    t.integer  "order_id",   :limit => 11
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_surveys", :force => true do |t|
    t.integer  "step_commercial_id", :limit => 11
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "parent_id",   :limit => 11
    t.string   "description"
    t.integer  "position",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_flows", :force => true do |t|
    t.string   "type"
    t.string   "purchase_number"
    t.string   "file_number"
    t.integer  "supply_id",               :limit => 11
    t.integer  "supplier_id",             :limit => 11
    t.decimal  "fob_unit_price",                        :precision => 65, :scale => 18
    t.decimal  "tax_coefficient",                       :precision => 65, :scale => 18
    t.decimal  "quantity",                              :precision => 65, :scale => 18
    t.decimal  "previous_stock_quantity",               :precision => 65, :scale => 18
    t.decimal  "previous_stock_value",                  :precision => 65, :scale => 18
    t.boolean  "adjustment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplier_supplies", :force => true do |t|
    t.string   "reference"
    t.string   "name"
    t.integer  "supply_id",       :limit => 11
    t.integer  "supplier_id",     :limit => 11
    t.integer  "lead_time",       :limit => 11
    t.decimal  "fob_unit_price",                :precision => 65, :scale => 18
    t.decimal  "tax_coefficient",               :precision => 65, :scale => 18
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplies", :force => true do |t|
    t.string   "name"
    t.string   "reference"
    t.string   "type"
    t.decimal  "measure",                              :precision => 65, :scale => 18
    t.decimal  "unit_mass",                            :precision => 65, :scale => 18
    t.decimal  "threshold",                            :precision => 65, :scale => 18
    t.integer  "commodity_category_id",  :limit => 11
    t.integer  "consumable_category_id", :limit => 11
    t.boolean  "enable",                                                               :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :limit => 11
    t.integer  "taggable_id",   :limit => 11
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "third_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "thirds", :force => true do |t|
    t.string   "name"
    t.string   "siret_number"
    t.integer  "activity_sector_id",    :limit => 11
    t.string   "activities"
    t.integer  "note",                  :limit => 11, :default => 0
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legal_form_id",         :limit => 11
    t.integer  "payment_method_id",     :limit => 11
    t.integer  "payment_time_limit_id", :limit => 11
    t.boolean  "activated",                           :default => true
  end

  create_table "unit_measures", :force => true do |t|
    t.string   "name"
    t.string   "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.boolean  "enabled"
    t.datetime "password_updated_at"
    t.datetime "last_connection"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_activity"
  end

end
