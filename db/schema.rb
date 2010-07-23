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

ActiveRecord::Schema.define(:version => 20100705104400) do

  create_table "activity_sector_references", :force => true do |t|
    t.integer "activity_sector_id",        :limit => 11
    t.integer "custom_activity_sector_id", :limit => 11
    t.string  "code"
  end

  add_index "activity_sector_references", ["code"], :name => "index_activity_sector_references_on_code", :unique => true

  create_table "activity_sectors", :force => true do |t|
    t.string "type"
    t.string "name"
  end

  add_index "activity_sectors", ["name", "type"], :name => "index_activity_sectors_on_name_and_type", :unique => true

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

  create_table "adjustments", :force => true do |t|
    t.integer  "due_date_id",             :limit => 11
    t.decimal  "amount",                                :precision => 65, :scale => 20
    t.text     "comment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
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
    t.integer  "end_product_id",      :limit => 11
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

  create_table "customer_grades", :force => true do |t|
    t.string  "name"
    t.integer "payment_time_limit_id", :limit => 11
  end

  create_table "customer_solvencies", :force => true do |t|
    t.string  "name"
    t.integer "payment_method_id", :limit => 11
  end

  create_table "delivery_interventions", :force => true do |t|
    t.integer  "delivery_note_id",                         :limit => 11
    t.integer  "scheduled_internal_actor_id",              :limit => 11
    t.integer  "scheduled_delivery_subcontractor_id",      :limit => 11
    t.integer  "scheduled_installation_subcontractor_id",  :limit => 11
    t.datetime "scheduled_delivery_at"
    t.integer  "scheduled_intervention_hours",             :limit => 11
    t.integer  "scheduled_intervention_minutes",           :limit => 11
    t.text     "scheduled_delivery_vehicles_rental"
    t.text     "scheduled_installation_equipments_rental"
    t.boolean  "delivered"
    t.boolean  "postponed"
    t.integer  "internal_actor_id",                        :limit => 11
    t.integer  "delivery_subcontractor_id",                :limit => 11
    t.integer  "installation_subcontractor_id",            :limit => 11
    t.datetime "delivery_at"
    t.integer  "intervention_hours",                       :limit => 11
    t.integer  "intervention_minutes",                     :limit => 11
    t.text     "delivery_vehicles_rental"
    t.text     "installation_equipments_rental"
    t.text     "comments"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size",                         :limit => 11
    t.integer  "cancelled_by_id",                          :limit => 11
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_deliverers", :force => true do |t|
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "deliverer_id",             :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_delivery_vehicles", :force => true do |t|
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "delivery_vehicle_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_installation_equipments", :force => true do |t|
    t.integer  "delivery_intervention_id",  :limit => 11
    t.integer  "installation_equipment_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_installers", :force => true do |t|
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "installer_id",             :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_deliverers", :force => true do |t|
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "scheduled_deliverer_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_delivery_vehicles", :force => true do |t|
    t.integer  "delivery_intervention_id",      :limit => 11
    t.integer  "scheduled_delivery_vehicle_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_installation_equipments", :force => true do |t|
    t.integer  "delivery_intervention_id",            :limit => 11
    t.integer  "scheduled_installation_equipment_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_installers", :force => true do |t|
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "scheduled_installer_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_invoices", :force => true do |t|
    t.integer  "delivery_note_id", :limit => 11
    t.integer  "invoice_id",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_items", :force => true do |t|
    t.integer  "delivery_note_id", :limit => 11
    t.integer  "quote_item_id",    :limit => 11
    t.integer  "quantity",         :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_types", :force => true do |t|
    t.string   "title"
    t.boolean  "delivery"
    t.boolean  "installation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_notes", :force => true do |t|
    t.integer  "order_id",                :limit => 11
    t.integer  "creator_id",              :limit => 11
    t.integer  "delivery_note_type_id",   :limit => 11
    t.string   "status"
    t.string   "reference"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
    t.date     "published_on"
    t.date     "signed_on"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_notes", ["reference"], :name => "index_delivery_notes_on_reference", :unique => true

  create_table "delivery_steps", :force => true do |t|
    t.integer  "pre_invoicing_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discards", :force => true do |t|
    t.integer  "delivery_note_item_id",    :limit => 11
    t.integer  "delivery_intervention_id", :limit => 11
    t.integer  "quantity",                 :limit => 11
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discards", ["delivery_note_item_id", "delivery_intervention_id"], :name => "index_discards_on_delivery_note_item_and_delivery_intervention", :unique => true

  create_table "document_sending_methods", :force => true do |t|
    t.string "name"
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

  create_table "due_dates", :force => true do |t|
    t.integer  "invoice_id",  :limit => 11
    t.date     "date"
    t.decimal  "net_to_paid",               :precision => 65, :scale => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dunning_sending_methods", :force => true do |t|
    t.string "name"
  end

  create_table "dunnings", :force => true do |t|
    t.integer  "creator_id",                :limit => 11
    t.integer  "dunning_sending_method_id", :limit => 11
    t.integer  "cancelled_by_id",           :limit => 11
    t.integer  "has_dunning_id",            :limit => 11
    t.string   "has_dunning_type"
    t.date     "date"
    t.text     "comment"
    t.datetime "cancelled_at"
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
    t.integer  "establishment_type_id",        :limit => 11
    t.integer  "customer_id",                  :limit => 11
    t.integer  "activity_sector_reference_id", :limit => 11
    t.string   "name"
    t.string   "type"
    t.string   "siret_number"
    t.boolean  "activated",                                  :default => true
    t.integer  "logo_file_size",               :limit => 11
    t.datetime "logo_updated_at"
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

  create_table "factors", :force => true do |t|
    t.string   "name"
    t.string   "fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "graphic_document_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_item_spool_items", :force => true do |t|
    t.integer  "user_id",         :limit => 11
    t.integer  "graphic_item_id", :limit => 11
    t.string   "path"
    t.string   "file_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_item_versions", :force => true do |t|
    t.integer  "graphic_item_id",     :limit => 11
    t.string   "source_file_name"
    t.string   "image_file_name"
    t.string   "source_content_type"
    t.string   "image_content_type"
    t.integer  "source_file_size",    :limit => 11
    t.integer  "image_file_size",     :limit => 11
    t.boolean  "is_current_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_items", :force => true do |t|
    t.integer  "creator_id",               :limit => 11
    t.integer  "graphic_unit_measure_id",  :limit => 11
    t.integer  "graphic_document_type_id", :limit => 11
    t.integer  "mockup_type_id",           :limit => 11
    t.integer  "order_id",                 :limit => 11
    t.integer  "press_proof_id",           :limit => 11
    t.integer  "end_product_id",           :limit => 11
    t.string   "type"
    t.string   "name"
    t.string   "reference"
    t.text     "description"
    t.boolean  "cancelled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_unit_measures", :force => true do |t|
    t.string   "name"
    t.string   "symbol"
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

  create_table "inventories", :force => true do |t|
    t.string   "supply_type"
    t.datetime "created_at"
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "invoice_id",     :limit => 11
    t.integer  "end_product_id", :limit => 11
    t.integer  "position",       :limit => 11
    t.float    "quantity"
    t.string   "name"
    t.text     "description"
    t.decimal  "unit_price",                   :precision => 65, :scale => 20
    t.float    "vat"
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

  create_table "invoice_types", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.boolean  "factorisable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "order_id",                    :limit => 11
    t.integer  "factor_id",                   :limit => 11
    t.integer  "invoice_type_id",             :limit => 11
    t.integer  "send_invoice_method_id",      :limit => 11
    t.integer  "creator_id",                  :limit => 11
    t.integer  "cancelled_by_id",             :limit => 11
    t.integer  "abandoned_by_id",             :limit => 11
    t.string   "reference"
    t.string   "status"
    t.text     "cancelled_comment"
    t.text     "abandoned_comment"
    t.text     "factoring_recovered_comment"
    t.date     "published_on"
    t.date     "sended_on"
    t.date     "abandoned_on"
    t.date     "factoring_recovered_on"
    t.date     "factoring_balance_paid_on"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.float    "deposit"
    t.float    "deposit_vat"
    t.decimal  "deposit_amount",                            :precision => 65, :scale => 20
    t.text     "deposit_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoices", ["reference"], :name => "index_invoices_on_reference", :unique => true

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

  create_table "mockup_types", :force => true do |t|
    t.string   "name"
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
    t.string   "has_number_key"
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
    t.string   "reference"
    t.text     "customer_needs"
    t.datetime "closed_at"
    t.date     "previsional_delivery"
    t.date     "quotation_deadline"
    t.integer  "delivery_time",              :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["reference"], :name => "index_orders_on_reference", :unique => true

  create_table "parcel_items", :force => true do |t|
    t.integer  "parcel_id",                      :limit => 11
    t.integer  "purchase_order_supply_id",       :limit => 11
    t.integer  "issue_purchase_order_supply_id", :limit => 11
    t.integer  "quantity",                       :limit => 11
    t.integer  "issues_quantity",                :limit => 11
    t.integer  "cancelled_by",                   :limit => 11
    t.string   "status"
    t.text     "issues_comment"
    t.text     "cancelled_comment"
    t.datetime "cancelled_at"
    t.date     "issued_at"
    t.boolean  "must_be_reshipped"
    t.boolean  "send_back_to_supplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parcels", :force => true do |t|
    t.integer  "delivery_document_id",         :limit => 11
    t.integer  "cancelled_by",                 :limit => 11
    t.integer  "status",                       :limit => 11
    t.string   "reference"
    t.string   "conveyance"
    t.text     "cancelled_comment"
    t.datetime "cancelled_at"
    t.date     "previsional_delivery_date"
    t.date     "processing_by_supplier_since"
    t.date     "shipped_on"
    t.date     "received_by_forwarder_on"
    t.date     "received_on"
    t.boolean  "awaiting_pick_up"
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

  add_index "payment_methods", ["name"], :name => "index_payment_methods_on_name", :unique => true

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

  add_index "payment_time_limits", ["name"], :name => "index_payment_time_limits_on_name", :unique => true

  create_table "payments", :force => true do |t|
    t.integer  "due_date_id",             :limit => 11
    t.integer  "payment_method_id",       :limit => 11
    t.date     "paid_on"
    t.decimal  "amount",                                :precision => 65, :scale => 20
    t.string   "bank_name"
    t.string   "payment_identifier"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    :limit => 11
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
    t.decimal  "amount",                    :precision => 65, :scale => 20
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proof_items", :force => true do |t|
    t.integer  "press_proof_id",          :limit => 11
    t.integer  "graphic_item_version_id", :limit => 11
    t.integer  "position",                :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proof_steps", :force => true do |t|
    t.integer  "commercial_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proofs", :force => true do |t|
    t.integer  "order_id",                        :limit => 11
    t.integer  "end_product_id",                  :limit => 11
    t.integer  "creator_id",                      :limit => 11
    t.integer  "internal_actor_id",               :limit => 11
    t.integer  "revoked_by_id",                   :limit => 11
    t.integer  "document_sending_method_id",      :limit => 11
    t.string   "status"
    t.string   "reference"
    t.integer  "signed_press_proof_file_size",    :limit => 11
    t.string   "signed_press_proof_file_name"
    t.string   "signed_press_proof_content_type"
    t.text     "revoked_comment"
    t.date     "confirmed_on"
    t.date     "signed_on"
    t.date     "sended_on"
    t.date     "revoked_on"
    t.date     "cancelled_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "press_proofs", ["reference"], :name => "index_press_proofs_on_reference", :unique => true

  create_table "product_reference_categories", :force => true do |t|
    t.integer  "product_reference_category_id", :limit => 11
    t.string   "reference"
    t.string   "name"
    t.integer  "product_references_count",      :limit => 11, :default => 0
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "type"
    t.integer  "product_reference_category_id", :limit => 11
    t.integer  "end_products_count",            :limit => 11, :default => 0
    t.integer  "product_reference_id",          :limit => 11
    t.integer  "order_id",                      :limit => 11
    t.float    "prizegiving"
    t.float    "unit_price"
    t.integer  "quantity",                      :limit => 11
    t.integer  "position",                      :limit => 11
    t.string   "reference"
    t.string   "name"
    t.string   "dimensions"
    t.text     "description"
    t.float    "vat"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_items", :force => true do |t|
    t.integer  "quote_id",       :limit => 11
    t.integer  "end_product_id", :limit => 11
    t.string   "name"
    t.text     "description"
    t.string   "dimensions"
    t.decimal  "unit_price",                   :precision => 65, :scale => 20
    t.decimal  "prizegiving",                  :precision => 65, :scale => 20
    t.float    "quantity"
    t.float    "vat"
    t.integer  "position",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["reference"], :name => "index_products_on_reference", :unique => true

  create_table "purchase_documents", :force => true do |t|
    t.string   "purchase_document_file_name"
    t.string   "purchase_document_content_type"
    t.integer  "purchase_document_file_size",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_order_supplies", :force => true do |t|
    t.integer  "purchase_order_id",    :limit => 11
    t.integer  "supply_id",            :limit => 11
    t.integer  "cancelled_by",         :limit => 11
    t.integer  "quantity",             :limit => 11
    t.float    "taxes"
    t.float    "fob_unit_price"
    t.string   "supplier_reference"
    t.string   "supplier_designation"
    t.text     "cancelled_comment"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "user_id",                      :limit => 11
    t.integer  "supplier_id",                  :limit => 11
    t.integer  "invoice_document_id",          :limit => 11
    t.integer  "quotation_document_id",        :limit => 11
    t.integer  "payment_document_id",          :limit => 11
    t.integer  "cancelled_by",                 :limit => 11
    t.integer  "status",                       :limit => 11
    t.string   "reference"
    t.string   "cancelled_comment"
    t.datetime "cancelled_at"
    t.date     "confirmed_on"
    t.date     "processing_by_supplier_since"
    t.date     "completed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_request_supplies", :force => true do |t|
    t.integer  "purchase_request_id",    :limit => 11
    t.integer  "supply_id",              :limit => 11
    t.integer  "cancelled_by",           :limit => 11
    t.integer  "expected_quantity",      :limit => 11
    t.datetime "cancelled_at"
    t.date     "expected_delivery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_requests", :force => true do |t|
    t.integer  "user_id",           :limit => 11
    t.integer  "employee_id",       :limit => 11
    t.integer  "service_id",        :limit => 11
    t.integer  "cancelled_by",      :limit => 11
    t.string   "reference"
    t.string   "cancelled_comment"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_items", :force => true do |t|
    t.integer  "quote_id",    :limit => 11
    t.integer  "product_id",  :limit => 11
    t.string   "name"
    t.text     "description"
    t.string   "dimensions"
    t.decimal  "unit_price",                :precision => 65, :scale => 20
    t.decimal  "prizegiving",               :precision => 65, :scale => 20
    t.float    "quantity"
    t.float    "vat"
    t.integer  "position",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "quote_steps", :force => true do |t|
    t.integer  "commercial_step_id", :limit => 11
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quotes", :force => true do |t|
    t.integer  "order_id",                :limit => 11
    t.integer  "creator_id",              :limit => 11
    t.integer  "send_quote_method_id",    :limit => 11
    t.integer  "order_form_type_id",      :limit => 11
    t.string   "status"
    t.string   "reference"
    t.float    "carriage_costs",                        :default => 0.0
    t.float    "prizegiving",                           :default => 0.0
    t.float    "deposit",                               :default => 0.0
    t.float    "discount",                              :default => 0.0
    t.text     "sales_terms"
    t.string   "validity_delay_unit"
    t.integer  "validity_delay",          :limit => 11
    t.string   "order_form_file_name"
    t.string   "order_form_content_type"
    t.integer  "order_form_file_size",    :limit => 11
    t.date     "confirmed_on"
    t.date     "cancelled_on"
    t.date     "sended_on"
    t.date     "signed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quotes", ["reference"], :name => "index_quotes_on_reference", :unique => true

  create_table "remarks", :force => true do |t|
    t.integer  "has_remark_id",   :limit => 11
    t.string   "has_remark_type"
    t.integer  "user_id",         :limit => 11
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_order_supplies", :force => true do |t|
    t.integer  "purchase_request_supply_id", :limit => 11
    t.integer  "purchase_order_supply_id",   :limit => 11
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
    t.decimal  "gross_amount",                  :precision => 65, :scale => 20
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

  create_table "send_invoice_methods", :force => true do |t|
    t.string "name"
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

  create_table "stock_flows", :force => true do |t|
    t.integer  "supply_id",               :limit => 11
    t.integer  "inventory_id",            :limit => 11
    t.string   "type"
    t.string   "identifier"
    t.decimal  "unit_price",                            :precision => 65, :scale => 18
    t.decimal  "previous_stock_value",                  :precision => 65, :scale => 18
    t.integer  "quantity",                :limit => 11
    t.integer  "previous_stock_quantity", :limit => 11
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

  create_table "supplier_supplies", :force => true do |t|
    t.integer  "supplier_id",          :limit => 11
    t.integer  "supply_id",            :limit => 11
    t.string   "supplier_reference"
    t.string   "supplier_designation"
    t.integer  "lead_time",            :limit => 11
    t.decimal  "fob_unit_price",                     :precision => 65, :scale => 18
    t.decimal  "taxes",                              :precision => 65, :scale => 18
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplies", :force => true do |t|
    t.integer  "supply_sub_category_id", :limit => 11
    t.string   "type"
    t.string   "reference"
    t.string   "name"
    t.string   "packaging"
    t.decimal  "measure",                              :precision => 65, :scale => 18
    t.decimal  "unit_mass",                            :precision => 65, :scale => 18
    t.decimal  "threshold",                            :precision => 65, :scale => 18
    t.boolean  "enabled",                                                              :default => true
    t.date     "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplies_supply_sizes", :force => true do |t|
    t.integer  "supply_id",       :limit => 11
    t.integer  "supply_size_id",  :limit => 11
    t.integer  "unit_measure_id", :limit => 11
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supply_categories", :force => true do |t|
    t.integer  "supply_category_id", :limit => 11
    t.integer  "unit_measure_id",    :limit => 11
    t.string   "type"
    t.string   "reference"
    t.string   "name"
    t.integer  "supplies_count",     :limit => 11, :default => 0
    t.boolean  "enabled",                          :default => true
    t.date     "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supply_categories", ["reference"], :name => "index_supply_categories_on_reference", :unique => true
  add_index "supply_categories", ["name", "type", "supply_category_id"], :name => "index_supply_categories_on_name_and_type_and_supply_category_id", :unique => true

  create_table "supply_categories_supply_sizes", :force => true do |t|
    t.integer  "supply_sub_category_id", :limit => 11
    t.integer  "supply_size_id",         :limit => 11
    t.integer  "unit_measure_id",        :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supply_sizes", :force => true do |t|
    t.string  "name"
    t.string  "short_name"
    t.boolean "display_short_name"
    t.boolean "accept_string"
    t.integer "position",           :limit => 11
  end

  add_index "supply_sizes", ["name"], :name => "index_supply_sizes_on_name", :unique => true

  create_table "supply_sizes_unit_measures", :force => true do |t|
    t.integer "supply_size_id",  :limit => 11
    t.integer "unit_measure_id", :limit => 11
    t.integer "position",        :limit => 11
  end

  add_index "supply_sizes_unit_measures", ["supply_size_id", "unit_measure_id"], :name => "index_supply_sizes_unit_measures", :unique => true

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
    t.integer  "legal_form_id",                :limit => 11
    t.integer  "creator_id",                   :limit => 11
    t.string   "type"
    t.string   "name"
    t.string   "siret_number"
    t.string   "website"
    t.boolean  "activated",                                  :default => true
    t.date     "company_created_at"
    t.date     "collaboration_started_at"
    t.integer  "activity_sector_reference_id", :limit => 11
    t.integer  "factor_id",                    :limit => 11
    t.integer  "customer_solvency_id",         :limit => 11
    t.integer  "customer_grade_id",            :limit => 11
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size",               :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_events", :force => true do |t|
    t.integer  "tool_id",           :limit => 11
    t.integer  "internal_actor_id", :limit => 11
    t.integer  "event_id",          :limit => 11
    t.integer  "status",            :limit => 11
    t.integer  "event_type",        :limit => 11
    t.date     "start_date"
    t.date     "end_date"
    t.text     "comment"
    t.string   "name"
    t.string   "provider_society"
    t.string   "provider_actor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tools", :force => true do |t|
    t.integer  "service_id",     :limit => 11
    t.integer  "job_id",         :limit => 11
    t.integer  "employee_id",    :limit => 11
    t.integer  "supplier_id",    :limit => 11
    t.string   "name"
    t.string   "serial_number"
    t.string   "type"
    t.text     "description"
    t.date     "purchase_date"
    t.float    "purchase_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unit_measures", :force => true do |t|
    t.string "name"
    t.string "symbol"
  end

  add_index "unit_measures", ["name"], :name => "index_unit_measures_on_name", :unique => true
  add_index "unit_measures", ["symbol"], :name => "index_unit_measures_on_symbol", :unique => true

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
