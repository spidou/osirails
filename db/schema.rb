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

ActiveRecord::Schema.define(:version => 20120223071650) do

  create_table "active_counters", :force => true do |t|
    t.string "key"
    t.string "cast_type"
    t.float  "value",     :default => 0.0
    t.string "model"
  end

  add_index "active_counters", ["model", "key"], :name => "index_active_counters_on_model_and_key", :unique => true

  create_table "activity_sector_references", :force => true do |t|
    t.integer "activity_sector_id"
    t.integer "custom_activity_sector_id"
    t.string  "code"
  end

  add_index "activity_sector_references", ["code"], :name => "index_activity_sector_references_on_code", :unique => true

  create_table "activity_sectors", :force => true do |t|
    t.string "type"
    t.string "name"
  end

  add_index "activity_sectors", ["name", "type"], :name => "index_activity_sectors_on_name_and_type", :unique => true

  create_table "addresses", :force => true do |t|
    t.integer  "has_address_id"
    t.string   "has_address_type"
    t.string   "has_address_key"
    t.text     "street_name"
    t.string   "country_name"
    t.string   "region_name"
    t.string   "city_name"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adjustments", :force => true do |t|
    t.integer  "due_date_id"
    t.decimal  "amount",                  :precision => 65, :scale => 20
    t.text     "comment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alarms", :force => true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.string   "description"
    t.string   "email_to"
    t.string   "action"
    t.integer  "do_alarm_before"
    t.integer  "duration"
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
    t.integer  "user_id"
    t.string   "name"
    t.string   "title"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "employee_id"
    t.date     "date"
    t.integer  "absence_hours"
    t.integer  "absence_minutes"
    t.integer  "overtime_hours"
    t.integer  "overtime_minutes"
    t.text     "absence_comment"
    t.text     "overtime_comment"
    t.boolean  "cancelled",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_options", :force => true do |t|
    t.integer  "checklist_id"
    t.integer  "parent_id"
    t.integer  "position"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_options_order_types", :force => true do |t|
    t.integer  "checklist_option_id"
    t.integer  "order_type_id"
    t.boolean  "activated",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_responses", :force => true do |t|
    t.integer  "checklist_option_id"
    t.integer  "end_product_id"
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
    t.integer "country_id"
    t.integer "region_id"
    t.string  "name"
    t.string  "zip_code"
  end

  create_table "civilities", :force => true do |t|
    t.string "name"
  end

  create_table "commercial_steps", :force => true do |t|
    t.integer  "order_id"
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

  create_table "contacts", :force => true do |t|
    t.integer  "has_contact_id"
    t.string   "has_contact_type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "job"
    t.string   "email"
    t.string   "gender"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.boolean  "hidden",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_versions", :force => true do |t|
    t.integer  "menu_id"
    t.integer  "content_id"
    t.integer  "contributor_id"
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.datetime "versioned_at"
  end

  create_table "contents", :force => true do |t|
    t.integer  "menu_id"
    t.integer  "author_id"
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.string   "contributors"
    t.integer  "lock_version", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "customer_grades", :force => true do |t|
    t.integer "granted_payment_time_id"
    t.string  "name"
  end

  create_table "customer_solvencies", :force => true do |t|
    t.integer "granted_payment_method_id"
    t.string  "name"
  end

  create_table "delivering_steps", :force => true do |t|
    t.integer  "order_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions", :force => true do |t|
    t.integer  "delivery_note_id"
    t.integer  "scheduled_internal_actor_id"
    t.integer  "scheduled_delivery_subcontractor_id"
    t.integer  "scheduled_installation_subcontractor_id"
    t.datetime "scheduled_delivery_at"
    t.integer  "scheduled_intervention_hours"
    t.integer  "scheduled_intervention_minutes"
    t.text     "scheduled_delivery_vehicles_rental"
    t.text     "scheduled_installation_equipments_rental"
    t.boolean  "delivered"
    t.boolean  "postponed"
    t.integer  "internal_actor_id"
    t.integer  "delivery_subcontractor_id"
    t.integer  "installation_subcontractor_id"
    t.datetime "delivery_at"
    t.integer  "intervention_hours"
    t.integer  "intervention_minutes"
    t.text     "delivery_vehicles_rental"
    t.text     "installation_equipments_rental"
    t.text     "comments"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size"
    t.integer  "cancelled_by_id"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_deliverers", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "deliverer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_delivery_vehicles", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "delivery_vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_installation_equipments", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "installation_equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_installers", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "installer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_deliverers", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "scheduled_deliverer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_delivery_vehicles", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "scheduled_delivery_vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_installation_equipments", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "scheduled_installation_equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_interventions_scheduled_installers", :force => true do |t|
    t.integer  "delivery_intervention_id"
    t.integer  "scheduled_installer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_invoices", :force => true do |t|
    t.integer  "delivery_note_id"
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_items", :force => true do |t|
    t.integer  "delivery_note_id"
    t.integer  "end_product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_note_types", :force => true do |t|
    t.string   "title"
    t.boolean  "delivery",     :default => false
    t.boolean  "installation", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_notes", :force => true do |t|
    t.integer  "order_id"
    t.integer  "creator_id"
    t.integer  "delivery_note_type_id"
    t.integer  "delivery_note_contact_id"
    t.string   "status"
    t.string   "reference"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.date     "published_on"
    t.date     "signed_on"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_notes", ["reference"], :name => "index_delivery_notes_on_reference", :unique => true

  create_table "delivery_steps", :force => true do |t|
    t.integer  "delivering_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discards", :force => true do |t|
    t.integer  "delivery_note_item_id"
    t.integer  "delivery_intervention_id"
    t.integer  "quantity"
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
    t.integer "document_type_id"
    t.integer "mime_type_id"
  end

  create_table "documents", :force => true do |t|
    t.integer  "has_document_id"
    t.string   "has_document_type"
    t.integer  "document_type_id"
    t.string   "name"
    t.string   "description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "due_dates", :force => true do |t|
    t.integer  "invoice_id"
    t.date     "date"
    t.decimal  "net_to_paid", :precision => 65, :scale => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dunning_sending_methods", :force => true do |t|
    t.string "name"
  end

  create_table "dunnings", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "dunning_sending_method_id"
    t.integer  "cancelled_by_id"
    t.integer  "has_dunning_id"
    t.string   "has_dunning_type"
    t.date     "date"
    t.text     "comment"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_sensitive_datas", :force => true do |t|
    t.integer  "family_situation_id"
    t.integer  "employee_id"
    t.string   "social_security_number"
    t.string   "email"
    t.date     "birth_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_states", :force => true do |t|
    t.string   "name"
    t.boolean  "active",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "service_id"
    t.integer  "civility_id"
    t.integer  "family_situation_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "society_email"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees_jobs", :id => false, :force => true do |t|
    t.integer  "job_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "establishment_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "establishments", :force => true do |t|
    t.integer  "establishment_type_id"
    t.integer  "customer_id"
    t.integer  "activity_sector_reference_id"
    t.string   "name"
    t.string   "type"
    t.string   "siret_number"
    t.boolean  "activated",                    :default => true
    t.boolean  "hidden",                       :default => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_categories", :force => true do |t|
    t.integer "calendar_id"
    t.string  "name"
  end

  create_table "events", :force => true do |t|
    t.integer  "calendar_id"
    t.integer  "event_category_id"
    t.integer  "organizer_id"
    t.string   "title"
    t.string   "color"
    t.string   "frequence"
    t.string   "status"
    t.boolean  "full_day",          :default => false, :null => false
    t.text     "location"
    t.text     "description"
    t.text     "link"
    t.integer  "interval",          :default => 1,     :null => false
    t.integer  "count"
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
    t.integer "event_id"
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
    t.integer  "file_type_id"
    t.integer  "mime_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "granted_payment_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "granted_payment_methods", ["name"], :name => "index_granted_payment_methods_on_name", :unique => true

  create_table "granted_payment_times", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "granted_payment_times", ["name"], :name => "index_granted_payment_times_on_name", :unique => true

  create_table "graphic_document_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_item_spool_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "graphic_item_id"
    t.string   "path"
    t.string   "file_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_item_versions", :force => true do |t|
    t.integer  "graphic_item_id"
    t.string   "source_file_name"
    t.string   "image_file_name"
    t.string   "source_content_type"
    t.string   "image_content_type"
    t.integer  "source_file_size"
    t.integer  "image_file_size"
    t.boolean  "is_current_version",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphic_items", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "graphic_unit_measure_id"
    t.integer  "graphic_document_type_id"
    t.integer  "mockup_type_id"
    t.integer  "order_id"
    t.integer  "press_proof_id"
    t.integer  "end_product_id"
    t.string   "type"
    t.string   "name"
    t.string   "reference"
    t.text     "description"
    t.boolean  "cancelled",                :default => false
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
    t.integer  "has_iban_id"
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
    t.integer  "country_id"
    t.string   "indicative"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", :force => true do |t|
    t.string   "supply_class"
    t.datetime "created_at"
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "invoiceable_id"
    t.string   "invoiceable_type"
    t.integer  "position"
    t.float    "quantity"
    t.string   "name"
    t.text     "description"
    t.decimal  "unit_price",       :precision => 65, :scale => 20
    t.float    "vat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_steps", :force => true do |t|
    t.integer  "invoicing_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_types", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.boolean  "factorisable", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "order_id"
    t.integer  "factor_id"
    t.integer  "invoice_type_id"
    t.integer  "send_invoice_method_id"
    t.integer  "invoicing_actor_id"
    t.integer  "invoice_contact_id"
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
    t.decimal  "deposit_amount",              :precision => 65, :scale => 20
    t.text     "deposit_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoices", ["reference"], :name => "index_invoices_on_reference", :unique => true

  create_table "invoicing_steps", :force => true do |t|
    t.integer  "order_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_contract_types", :force => true do |t|
    t.string   "name"
    t.boolean  "limited",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_contracts", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "job_contract_type_id"
    t.date     "start_date"
    t.date     "end_date"
    t.date     "departure"
    t.text     "departure_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "service_id"
    t.string   "name"
    t.boolean  "responsible", :default => false
    t.text     "mission"
    t.text     "activity"
    t.text     "goal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_identifiers", :force => true do |t|
    t.integer "journalized_id"
    t.string  "journalized_type"
    t.integer "journal_id"
    t.string  "old_value"
    t.string  "new_value"
  end

  create_table "journal_lines", :force => true do |t|
    t.integer "journal_id"
    t.integer "referenced_journal_id"
    t.string  "property"
    t.string  "property_type"
    t.string  "old_value"
    t.string  "new_value"
    t.integer "property_id"
  end

  create_table "journals", :force => true do |t|
    t.integer  "journalized_id"
    t.string   "journalized_type"
    t.integer  "actor_id"
    t.datetime "created_at"
  end

  create_table "leave_requests", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "leave_type_id"
    t.integer  "responsible_id"
    t.integer  "observer_id"
    t.integer  "director_id"
    t.integer  "cancelled_by"
    t.integer  "status"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "checked_at"
    t.datetime "noticed_at"
    t.datetime "ended_at"
    t.datetime "cancelled_at"
    t.boolean  "start_half",            :default => false
    t.boolean  "end_half",              :default => false
    t.boolean  "responsible_agreement", :default => false
    t.boolean  "director_agreement",    :default => false
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
    t.integer  "employee_id"
    t.integer  "leave_type_id"
    t.integer  "leave_request_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "start_half",       :default => false
    t.boolean  "end_half",         :default => false
    t.boolean  "cancelled",        :default => false
    t.float    "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legal_forms", :force => true do |t|
    t.integer  "third_type_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manufacturing_progresses", :force => true do |t|
    t.integer  "manufacturing_step_id"
    t.integer  "end_product_id"
    t.integer  "progression"
    t.integer  "building_quantity"
    t.integer  "built_quantity"
    t.integer  "available_to_deliver_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manufacturing_steps", :force => true do |t|
    t.integer  "production_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.date     "manufacturing_started_on"
    t.date     "manufacturing_finished_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memorandums", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "subject"
    t.string   "signature"
    t.text     "text"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memorandums_services", :force => true do |t|
    t.integer  "service_id"
    t.integer  "memorandum_id"
    t.boolean  "recursive",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "feature_id"
    t.string   "name"
    t.string   "title"
    t.string   "description"
    t.string   "separator"
    t.integer  "position"
    t.boolean  "hidden",      :default => false
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
    t.integer  "orders_steps_id"
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
    t.integer  "has_number_id"
    t.string   "has_number_type"
    t.string   "has_number_key"
    t.integer  "indicative_id"
    t.integer  "number_type_id"
    t.string   "number"
    t.boolean  "visible",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_form_types", :force => true do |t|
    t.string "name"
  end

  create_table "order_logs", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
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

  create_table "orders", :force => true do |t|
    t.integer  "commercial_id"
    t.integer  "user_id"
    t.integer  "customer_id"
    t.integer  "order_type_id"
    t.integer  "approaching_id"
    t.integer  "order_contact_id"
    t.string   "title"
    t.string   "reference"
    t.text     "customer_needs"
    t.date     "previsional_delivery"
    t.date     "quotation_deadline"
    t.integer  "delivery_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.date     "standby_on"
    t.date     "discarded_on"
    t.date     "completed_on"
  end

  add_index "orders", ["reference"], :name => "index_orders_on_reference", :unique => true

  create_table "orders_service_deliveries", :force => true do |t|
    t.integer  "order_id"
    t.integer  "service_delivery_id"
    t.string   "name"
    t.text     "description"
    t.float    "cost"
    t.decimal  "margin",              :precision => 65, :scale => 20
    t.decimal  "prizegiving",         :precision => 65, :scale => 20
    t.float    "quantity"
    t.float    "vat"
    t.integer  "position"
    t.boolean  "pro_rata_billing",                                    :default => false
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", :force => true do |t|
    t.integer  "event_id"
    t.integer  "employee_id"
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
    t.integer  "invoicing_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "due_date_id"
    t.integer  "payment_method_id"
    t.date     "paid_on"
    t.decimal  "amount",                  :precision => 65, :scale => 20
    t.string   "bank_name"
    t.string   "payment_identifier"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_methods", :force => true do |t|
    t.string "name"
    t.string "title"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id"
    t.string   "has_permissions_type"
    t.integer  "has_permissions_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_permission_methods", :force => true do |t|
    t.integer  "permission_id"
    t.integer  "permission_method_id"
    t.boolean  "active",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "premia", :force => true do |t|
    t.integer  "employee_sensitive_data_id"
    t.date     "date"
    t.decimal  "amount",                     :precision => 65, :scale => 20
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proof_items", :force => true do |t|
    t.integer  "press_proof_id"
    t.integer  "graphic_item_version_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proof_steps", :force => true do |t|
    t.integer  "commercial_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "press_proofs", :force => true do |t|
    t.integer  "order_id"
    t.integer  "end_product_id"
    t.integer  "creator_id"
    t.integer  "internal_actor_id"
    t.integer  "revoked_by_id"
    t.integer  "document_sending_method_id"
    t.string   "status"
    t.string   "reference"
    t.integer  "signed_press_proof_file_size"
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
    t.integer  "product_reference_category_id"
    t.integer  "product_references_count",      :default => 0
    t.string   "type"
    t.string   "reference"
    t.string   "name"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_reference_categories", ["name", "type", "product_reference_category_id"], :name => "index_product_reference_categories_on_name", :unique => true
  add_index "product_reference_categories", ["reference"], :name => "index_product_reference_categories_on_reference", :unique => true

  create_table "production_steps", :force => true do |t|
    t.integer  "order_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "type"
    t.integer  "product_reference_sub_category_id"
    t.integer  "end_products_count",                :default => 0
    t.integer  "product_reference_id"
    t.integer  "order_id"
    t.float    "prizegiving"
    t.float    "unit_price"
    t.integer  "quantity"
    t.integer  "position"
    t.string   "reference"
    t.string   "name"
    t.integer  "width"
    t.integer  "length"
    t.integer  "height"
    t.text     "description"
    t.float    "vat"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queries", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "page_name"
    t.string   "search_type"
    t.string   "quick_search_value"
    t.text     "criteria"
    t.text     "columns"
    t.text     "order"
    t.text     "group"
    t.boolean  "public_access",      :default => false
    t.integer  "per_page"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_items", :force => true do |t|
    t.integer  "quote_id"
    t.integer  "quotable_id"
    t.string   "quotable_type"
    t.string   "name"
    t.text     "description"
    t.integer  "width"
    t.integer  "length"
    t.integer  "height"
    t.decimal  "unit_price",       :precision => 65, :scale => 20
    t.decimal  "prizegiving",      :precision => 65, :scale => 20
    t.float    "quantity"
    t.float    "vat"
    t.integer  "position"
    t.boolean  "pro_rata_billing",                                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_steps", :force => true do |t|
    t.integer  "commercial_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quotes", :force => true do |t|
    t.integer  "order_id"
    t.integer  "send_quote_method_id"
    t.integer  "order_form_type_id"
    t.integer  "commercial_actor_id"
    t.integer  "quote_contact_id"
    t.string   "status"
    t.string   "reference"
    t.float    "carriage_costs",          :default => 0.0
    t.float    "prizegiving",             :default => 0.0
    t.float    "deposit"
    t.text     "sales_terms"
    t.string   "validity_delay_unit"
    t.integer  "validity_delay"
    t.string   "order_form_file_name"
    t.string   "order_form_content_type"
    t.integer  "order_form_file_size"
    t.date     "published_on"
    t.date     "sended_on"
    t.date     "signed_on"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quotes", ["reference"], :name => "index_quotes_on_reference", :unique => true

  create_table "regions", :force => true do |t|
    t.integer "country_id"
    t.string  "name"
  end

  create_table "remarks", :force => true do |t|
    t.integer  "has_remark_id"
    t.string   "has_remark_type"
    t.integer  "user_id"
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
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "salaries", :force => true do |t|
    t.integer  "job_contract_id"
    t.decimal  "gross_amount",    :precision => 65, :scale => 20
    t.datetime "created_at"
    t.decimal  "net_amount",      :precision => 65, :scale => 20
    t.date     "date"
  end

  create_table "sales_processes", :force => true do |t|
    t.integer  "order_type_id"
    t.integer  "step_id"
    t.boolean  "activated",          :default => true
    t.boolean  "depending_previous", :default => false
    t.boolean  "required",           :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_processes_steps", :force => true do |t|
    t.integer "sales_process_id"
    t.integer "step_id"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "service_id"
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

  create_table "service_deliveries", :force => true do |t|
    t.string   "reference"
    t.string   "name"
    t.text     "description"
    t.float    "cost"
    t.decimal  "margin",                   :precision => 65, :scale => 20
    t.float    "vat"
    t.string   "time_scale"
    t.boolean  "pro_rata_billable",                                        :default => false
    t.boolean  "default_pro_rata_billing",                                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.integer  "service_parent_id"
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
    t.integer  "order_id"
    t.integer  "establishment_id"
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
    t.integer  "step_id"
    t.integer  "step_dependent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "title"
    t.string   "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_flows", :force => true do |t|
    t.integer  "supply_id"
    t.integer  "inventory_id"
    t.string   "type"
    t.string   "identifier"
    t.decimal  "unit_price",              :precision => 65, :scale => 18
    t.decimal  "previous_stock_value",    :precision => 65, :scale => 18
    t.integer  "quantity"
    t.integer  "previous_stock_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcontractor_requests", :force => true do |t|
    t.integer "subcontractor_id"
    t.integer "survey_step_id"
    t.text    "job_needed"
    t.float   "price"
    t.string  "attachment_file_name"
    t.string  "attachment_content_type"
    t.integer "attachment_file_size"
  end

  create_table "supplier_supplies", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "supply_id"
    t.string   "supplier_reference"
    t.integer  "lead_time"
    t.decimal  "fob_unit_price",     :precision => 65, :scale => 18
    t.decimal  "taxes",              :precision => 65, :scale => 18
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplies", :force => true do |t|
    t.integer  "supply_type_id"
    t.string   "type"
    t.string   "reference"
    t.string   "packaging"
    t.decimal  "measure",        :precision => 65, :scale => 18
    t.decimal  "unit_mass",      :precision => 65, :scale => 18
    t.decimal  "threshold",      :precision => 65, :scale => 18
    t.boolean  "enabled",                                        :default => true
    t.datetime "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplies_supply_sizes", :force => true do |t|
    t.integer  "supply_id"
    t.integer  "supply_size_id"
    t.integer  "unit_measure_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supply_categories", :force => true do |t|
    t.integer  "supply_category_id"
    t.integer  "unit_measure_id"
    t.string   "type"
    t.string   "reference"
    t.string   "name"
    t.integer  "supplies_count",     :default => 0
    t.boolean  "enabled",            :default => true
    t.datetime "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supply_categories", ["name", "type", "supply_category_id"], :name => "index_supply_categories_on_name_and_type_and_supply_category_id", :unique => true
  add_index "supply_categories", ["reference"], :name => "index_supply_categories_on_reference", :unique => true

  create_table "supply_categories_supply_sizes", :force => true do |t|
    t.integer  "supply_sub_category_id"
    t.integer  "supply_size_id"
    t.integer  "unit_measure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supply_sizes", :force => true do |t|
    t.string  "name"
    t.string  "short_name"
    t.boolean "display_short_name", :default => false
    t.boolean "accept_string",      :default => false
    t.integer "position"
  end

  add_index "supply_sizes", ["name"], :name => "index_supply_sizes_on_name", :unique => true

  create_table "supply_sizes_unit_measures", :force => true do |t|
    t.integer "supply_size_id"
    t.integer "unit_measure_id"
    t.integer "position"
  end

  add_index "supply_sizes_unit_measures", ["supply_size_id", "unit_measure_id"], :name => "index_supply_sizes_unit_measures", :unique => true

  create_table "survey_interventions", :force => true do |t|
    t.integer  "survey_step_id"
    t.integer  "internal_actor_id"
    t.integer  "survey_intervention_contact_id"
    t.datetime "start_date"
    t.integer  "duration_hours"
    t.integer  "duration_minutes"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_steps", :force => true do |t|
    t.integer  "commercial_step_id"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
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
    t.integer  "legal_form_id"
    t.string   "type"
    t.string   "name"
    t.string   "website"
    t.boolean  "activated",                    :default => true
    t.date     "company_created_at"
    t.date     "collaboration_started_at"
    t.integer  "activity_sector_reference_id"
    t.string   "siret_number"
    t.integer  "factor_id"
    t.integer  "customer_solvency_id"
    t.integer  "customer_grade_id"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tool_events", :force => true do |t|
    t.integer  "tool_id"
    t.integer  "internal_actor_id"
    t.integer  "event_id"
    t.integer  "status"
    t.integer  "event_type"
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
    t.integer  "service_id"
    t.integer  "job_id"
    t.integer  "employee_id"
    t.integer  "supplier_id"
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
    t.boolean  "enabled",             :default => false
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
    t.integer "position"
  end

  create_table "watchable_functions", :force => true do |t|
    t.string  "watchable_type"
    t.string  "name"
    t.string  "description"
    t.boolean "on_modification", :default => false
    t.boolean "on_schedule",     :default => false
  end

  add_index "watchable_functions", ["name", "watchable_type"], :name => "index_watchable_functions_on_name_and_watchable_type", :unique => true

  create_table "watchings", :force => true do |t|
    t.integer "watchable_id"
    t.string  "watchable_type"
    t.integer "watcher_id"
    t.boolean "all_changes",    :default => false
  end

  add_index "watchings", ["watchable_id", "watchable_type", "watcher_id"], :name => "unique_index_watchings", :unique => true
  add_index "watchings", ["watchable_id", "watchable_type"], :name => "index_watchings_on_watchable_id_and_watchable_type"
  add_index "watchings", ["watcher_id"], :name => "index_watchings_on_watcher_id"

  create_table "watchings_watchable_functions", :force => true do |t|
    t.integer "watching_id"
    t.integer "watchable_function_id"
    t.boolean "on_modification",       :default => false
    t.boolean "on_schedule",           :default => false
    t.string  "time_quantity"
    t.string  "time_unity"
  end

  add_index "watchings_watchable_functions", ["watching_id", "watchable_function_id"], :name => "unique_index_watchings_watchable_functions", :unique => true

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "col"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
