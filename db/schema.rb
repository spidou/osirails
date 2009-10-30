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

ActiveRecord::Schema.define(:version => 20091026081226) do

  create_table "activity_sectors", :force => true do |t|
    t.string   "name"
    t.boolean  "activated",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.integer  "has_address_id",   :limit => 11
    t.string   "has_address_type"
    t.string   "has_address_key"
    t.text     "street_name"
    t.string   "country_name"
    t.string   "city_name"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alarms", :force => true do |t|
    t.integer  "event_id",        :limit => 11
    t.string   "title"
    t.string   "description"
    t.string   "email_to"
    t.string   "action"
    t.integer  "do_alarm_before", :limit => 11
    t.integer  "duration",        :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approachings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_objects", :force => true do |t|
    t.string "name"
  end

  add_index "business_objects", ["name"], :name => "index_business_objects_on_name", :unique => true

  create_table "calendars", :force => true do |t|
    t.integer  "user_id",    :limit => 11
    t.string   "name"
    t.string   "title"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkings", :force => true do |t|
    t.integer  "user_id",          :limit => 11
    t.integer  "employee_id",      :limit => 11
    t.date     "date"
    t.integer  "absence_hours",    :limit => 11
    t.integer  "absence_minutes",  :limit => 11
    t.integer  "overtime_hours",   :limit => 11
    t.integer  "overtime_minutes", :limit => 11
    t.text     "absence_comment"
    t.text     "overtime_comment"
    t.boolean  "cancelled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_options", :force => true do |t|
    t.integer  "checklist_id", :limit => 11
    t.integer  "parent_id",    :limit => 11
    t.integer  "position",     :limit => 11
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_options_order_types", :force => true do |t|
    t.integer  "checklist_option_id", :limit => 11
    t.integer  "order_type_id",       :limit => 11
    t.boolean  "activated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_responses", :force => true do |t|
    t.integer  "checklist_option_id", :limit => 11
    t.integer  "product_id",          :limit => 11
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklists", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.integer "country_id", :limit => 11
    t.string  "name"
    t.string  "zip_code"
  end

  create_table "civilities", :force => true do |t|
    t.string "name"
  end

  create_table "commercial_steps", :force => true do |t|
    t.integer  "order_id",    :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commodities", :force => true do |t|
    t.integer  "supplier_id",           :limit => 11
    t.integer  "commodity_category_id", :limit => 11
    t.string   "name"
    t.float    "fob_unit_price"
    t.float    "taxe_coefficient"
    t.float    "measure"
    t.float    "unit_mass"
    t.boolean  "enable",                              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commodities_inventories", :force => true do |t|
    t.integer  "commodity_id",                   :limit => 11
    t.integer  "inventory_id",                   :limit => 11
    t.integer  "parent_commodity_category_id",   :limit => 11
    t.integer  "commodity_category_id",          :limit => 11
    t.integer  "unit_measure_id",                :limit => 11
    t.integer  "supplier_id",                    :limit => 11
    t.string   "name"
    t.string   "commodity_category_name"
    t.string   "parent_commodity_category_name"
    t.float    "fob_unit_price"
    t.float    "taxe_coefficient"
    t.float    "measure"
    t.float    "unit_mass"
    t.float    "quantity",                                     :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commodity_categories", :force => true do |t|
    t.integer  "commodity_category_id", :limit => 11
    t.integer  "unit_measure_id",       :limit => 11
    t.string   "name"
    t.integer  "commodities_count",     :limit => 11, :default => 0
    t.boolean  "enable",                              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "value"
    t.datetime "created_at"
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
    t.integer  "contact_type_id",     :limit => 11
    t.string   "first_name"
    t.string   "last_name"
    t.string   "job"
    t.string   "email"
    t.string   "gender"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts_owners", :force => true do |t|
    t.integer  "has_contact_id",   :limit => 11
    t.string   "has_contact_type"
    t.integer  "contact_id",       :limit => 11
    t.integer  "contact_type_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_versions", :force => true do |t|
    t.integer  "menu_id",        :limit => 11
    t.integer  "content_id",     :limit => 11
    t.integer  "contributor_id", :limit => 11
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.datetime "versioned_at"
  end

  create_table "contents", :force => true do |t|
    t.integer  "menu_id",      :limit => 11
    t.integer  "author_id",    :limit => 11
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.string   "contributors"
    t.integer  "lock_version", :limit => 11, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "deliverers_interventions", :force => true do |t|
    t.integer "deliverer_id",    :limit => 11
    t.integer "intervention_id", :limit => 11
  end

  create_table "delivery_notes", :force => true do |t|
    t.integer  "delivery_step_id",        :limit => 11
    t.integer  "creator_id",              :limit => 11
    t.string   "status"
    t.date     "validated_on"
    t.date     "invalidated_on"
    t.date     "signed_on"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.string   "public_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_notes_quotes_product_references", :force => true do |t|
    t.integer  "delivery_note_id",            :limit => 11
    t.integer  "quotes_product_reference_id", :limit => 11
    t.integer  "report_type_id",              :limit => 11
    t.integer  "quantity",                    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_steps", :force => true do |t|
    t.integer  "pre_invoicing_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discard_types", :force => true do |t|
    t.string "name"
  end

  create_table "discards", :force => true do |t|
    t.integer  "delivery_notes_quotes_product_reference_id", :limit => 11
    t.integer  "discard_type_id",                            :limit => 11
    t.text     "comments"
    t.integer  "quantity",                                   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_types", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_types", ["name"], :name => "index_document_types_on_name", :unique => true

  create_table "document_types_mime_types", :id => false, :force => true do |t|
    t.integer "document_type_id", :limit => 11
    t.integer "mime_type_id",     :limit => 11
  end

  create_table "documents", :force => true do |t|
    t.integer  "has_document_id",         :limit => 11
    t.string   "has_document_type"
    t.integer  "document_type_id",        :limit => 11
    t.string   "name"
    t.string   "description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_states", :force => true do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.integer  "user_id",                :limit => 11
    t.integer  "service_id",             :limit => 11
    t.integer  "civility_id",            :limit => 11
    t.integer  "family_situation_id",    :limit => 11
    t.string   "first_name"
    t.string   "last_name"
    t.string   "social_security_number"
    t.string   "qualification"
    t.string   "email"
    t.string   "society_email"
    t.date     "birth_date"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size",       :limit => 11
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees_jobs", :id => false, :force => true do |t|
    t.integer  "job_id",      :limit => 11
    t.integer  "employee_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "establishment_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "establishments", :force => true do |t|
    t.integer  "establishment_type_id", :limit => 11
    t.integer  "customer_id",           :limit => 11
    t.string   "name"
    t.boolean  "activated",                           :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimate_steps", :force => true do |t|
    t.integer  "commercial_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
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
    t.integer  "organizer_id",      :limit => 11
    t.string   "title"
    t.string   "color"
    t.string   "frequence"
    t.string   "status"
    t.boolean  "full_day",                        :default => false, :null => false
    t.text     "location"
    t.text     "description"
    t.text     "link"
    t.integer  "interval",          :limit => 11, :default => 1,     :null => false
    t.integer  "count",             :limit => 11
    t.string   "by_day"
    t.string   "by_month_day"
    t.string   "by_month"
    t.datetime "start_at"
    t.datetime "end_at"
    t.date     "until_date"
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
    t.string   "title"
    t.string   "version"
    t.text     "dependencies"
    t.text     "conflicts"
    t.boolean  "installed",    :default => false, :null => false
    t.boolean  "activated",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "graphic_conception_steps", :force => true do |t|
    t.integer  "commercial_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ibans", :force => true do |t|
    t.integer  "has_iban_id",    :limit => 11
    t.string   "has_iban_type"
    t.string   "account_name"
    t.string   "bank_name"
    t.string   "bank_code"
    t.string   "branch_code"
    t.string   "account_number"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indicatives", :force => true do |t|
    t.integer  "country_id", :limit => 11
    t.string   "indicative"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interventions", :force => true do |t|
    t.integer  "delivery_note_id",      :limit => 11
    t.boolean  "on_site"
    t.datetime "scheduled_delivery_at"
    t.boolean  "delivered"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", :force => true do |t|
    t.boolean  "closed",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_steps", :force => true do |t|
    t.integer  "invoicing_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoicing_steps", :force => true do |t|
    t.integer  "order_id",    :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_contract_types", :force => true do |t|
    t.string   "name"
    t.boolean  "limited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_contracts", :force => true do |t|
    t.integer  "employee_id",          :limit => 11
    t.integer  "employee_state_id",    :limit => 11
    t.integer  "job_contract_type_id", :limit => 11
    t.date     "start_date"
    t.date     "end_date"
    t.date     "departure"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "service_id",  :limit => 11
    t.string   "name"
    t.boolean  "responsible"
    t.text     "mission"
    t.text     "activity"
    t.text     "goal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_requests", :force => true do |t|
    t.integer  "employee_id",           :limit => 11
    t.integer  "leave_type_id",         :limit => 11
    t.integer  "responsible_id",        :limit => 11
    t.integer  "observer_id",           :limit => 11
    t.integer  "director_id",           :limit => 11
    t.integer  "cancelled_by",          :limit => 11
    t.integer  "status",                :limit => 11
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "checked_at"
    t.datetime "noticed_at"
    t.datetime "ended_at"
    t.datetime "cancelled_at"
    t.boolean  "start_half"
    t.boolean  "end_half"
    t.boolean  "responsible_agreement"
    t.boolean  "director_agreement"
    t.text     "comment"
    t.text     "responsible_remarks"
    t.text     "observer_remarks"
    t.text     "director_remarks"
    t.float    "acquired_leaves_days"
    t.float    "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leaves", :force => true do |t|
    t.integer  "employee_id",      :limit => 11
    t.integer  "leave_type_id",    :limit => 11
    t.integer  "leave_request_id", :limit => 11
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "start_half"
    t.boolean  "end_half"
    t.boolean  "cancelled"
    t.float    "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legal_forms", :force => true do |t|
    t.integer  "third_type_id", :limit => 11
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memorandums", :force => true do |t|
    t.integer  "user_id",      :limit => 11
    t.string   "title"
    t.string   "subject"
    t.string   "signature"
    t.text     "text"
    t.datetime "published_at"
    t.datetime "created_at"
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
    t.integer  "parent_id",   :limit => 11
    t.integer  "feature_id",  :limit => 11
    t.string   "name"
    t.string   "title"
    t.string   "description"
    t.string   "separator"
    t.integer  "position",    :limit => 11
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "has_number_id",   :limit => 11
    t.string   "has_number_type"
    t.integer  "indicative_id",   :limit => 11
    t.integer  "number_type_id",  :limit => 11
    t.string   "number"
    t.boolean  "visible",                       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_form_types", :force => true do |t|
    t.string "name"
  end

  create_table "order_logs", :force => true do |t|
    t.integer  "order_id",   :limit => 11
    t.integer  "user_id",    :limit => 11
    t.string   "controller"
    t.string   "action"
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
    t.integer  "commercial_id",              :limit => 11
    t.integer  "user_id",                    :limit => 11
    t.integer  "customer_id",                :limit => 11
    t.integer  "establishment_id",           :limit => 11
    t.integer  "society_activity_sector_id", :limit => 11
    t.integer  "order_type_id",              :limit => 11
    t.integer  "approaching_id",             :limit => 11
    t.string   "title"
    t.text     "customer_needs"
    t.datetime "closed_at"
    t.date     "previsional_delivery"
    t.date     "quotation_deadline"
    t.integer  "delivery_time",              :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.integer  "event_id",    :limit => 11
    t.integer  "employee_id", :limit => 11
    t.text     "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_steps", :force => true do |t|
    t.integer  "invoicing_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
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

  create_table "pre_invoicing_steps", :force => true do |t|
    t.integer  "order_id",    :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "premia", :force => true do |t|
    t.integer  "employee_id", :limit => 11
    t.date     "date"
    t.decimal  "amount",                    :precision => 65, :scale => 30
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proofs", :force => true do |t|
    t.integer  "graphic_conception_step_id", :limit => 11
    t.string   "status"
    t.string   "transmission_mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_reference_categories", :force => true do |t|
    t.integer  "product_reference_category_id", :limit => 11
    t.string   "name"
    t.boolean  "enable",                                      :default => true
    t.integer  "product_references_count",      :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_references", :force => true do |t|
    t.integer  "product_reference_category_id", :limit => 11
    t.string   "reference"
    t.string   "name"
    t.text     "description"
    t.float    "production_cost_manpower"
    t.float    "production_time"
    t.float    "delivery_cost_manpower"
    t.float    "delivery_time"
    t.float    "vat"
    t.boolean  "enable",                                      :default => true
    t.integer  "products_count",                :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_references", ["reference"], :name => "index_product_references_on_reference", :unique => true

  create_table "products", :force => true do |t|
    t.integer  "product_reference_id", :limit => 11
    t.integer  "order_id",             :limit => 11
    t.string   "reference"
    t.string   "name"
    t.string   "dimensions"
    t.text     "description"
    t.float    "quantity"
    t.integer  "position",             :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["reference"], :name => "index_products_on_reference", :unique => true

  create_table "quotes", :force => true do |t|
    t.integer  "estimate_step_id",        :limit => 11
    t.integer  "user_id",                 :limit => 11
    t.integer  "send_quote_method_id",    :limit => 11
    t.integer  "order_form_type_id",      :limit => 11
    t.string   "status"
    t.string   "public_number"
    t.float    "carriage_costs",                        :default => 0.0
    t.float    "reduction",                             :default => 0.0
    t.float    "account",                               :default => 0.0
    t.string   "validity_delay_unit"
    t.integer  "validity_delay",          :limit => 11
    t.string   "order_form_file_name"
    t.string   "order_form_content_type"
    t.integer  "order_form_file_size",    :limit => 11
    t.date     "validated_on"
    t.date     "invalidated_on"
    t.date     "sended_on"
    t.date     "signed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quotes", ["public_number"], :name => "index_quotes_on_public_number", :unique => true

  create_table "quotes_product_references", :force => true do |t|
    t.integer  "quote_id",             :limit => 11
    t.integer  "product_reference_id", :limit => 11
    t.string   "name"
    t.string   "original_name"
    t.text     "description"
    t.text     "original_description"
    t.float    "unit_price"
    t.float    "original_unit_price"
    t.float    "vat"
    t.float    "discount"
    t.integer  "quantity",             :limit => 11
    t.integer  "position",             :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remarks", :force => true do |t|
    t.integer  "has_remark_id",   :limit => 11
    t.string   "has_remark_type"
    t.integer  "user_id",         :limit => 11
    t.text     "text"
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
    t.float    "gross_amount"
    t.datetime "created_at"
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
    t.integer  "service_id",      :limit => 11
    t.float    "morning_start"
    t.float    "morning_end"
    t.float    "afternoon_start"
    t.float    "afternoon_end"
    t.string   "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "send_quote_methods", :force => true do |t|
    t.string "name"
  end

  create_table "services", :force => true do |t|
    t.integer  "service_parent_id", :limit => 11
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "ship_to_addresses", :force => true do |t|
    t.integer  "order_id",           :limit => 11
    t.integer  "establishment_id",   :limit => 11
    t.string   "establishment_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "society_activity_sectors", :force => true do |t|
    t.string   "name"
    t.boolean  "activated",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "step_dependencies", :id => false, :force => true do |t|
    t.integer  "step_id",        :limit => 11
    t.integer  "step_dependent", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", :force => true do |t|
    t.integer  "parent_id",   :limit => 11
    t.string   "name"
    t.string   "title"
    t.string   "description"
    t.integer  "position",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcontractor_requests", :force => true do |t|
    t.integer "subcontractor_id",        :limit => 11
    t.integer "survey_step_id",          :limit => 11
    t.text    "job_needed"
    t.float   "price"
    t.string  "attachment_file_name"
    t.string  "attachment_content_type"
    t.integer "attachment_file_size",    :limit => 11
  end

  create_table "survey_interventions", :force => true do |t|
    t.integer  "survey_step_id",    :limit => 11
    t.integer  "internal_actor_id", :limit => 11
    t.datetime "start_date"
    t.integer  "duration_hours",    :limit => 11
    t.integer  "duration_minutes",  :limit => 11
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_steps", :force => true do |t|
    t.integer  "commercial_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
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
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thirds", :force => true do |t|
    t.integer  "legal_form_id",         :limit => 11
    t.integer  "activity_sector_id",    :limit => 11
    t.string   "type"
    t.string   "name"
    t.string   "siret_number"
    t.string   "activities"
    t.string   "website"
    t.integer  "note",                  :limit => 11, :default => 0
    t.boolean  "activated",                           :default => true
    t.integer  "payment_method_id",     :limit => 11
    t.integer  "payment_time_limit_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "last_activity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "vats", :force => true do |t|
    t.string  "name"
    t.float   "rate"
    t.integer "position", :limit => 11
  end

end
