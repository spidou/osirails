ActiveRecord::Schema.define do
  create_table "journal_identifiers", :force => true do |t|
    t.integer  "journalized_id",   :limit => 11
    t.string   "journalized_type"
    t.integer  "journal_id",       :limit => 11
    t.string   "old_value"
    t.string   "new_value"
  end

  create_table "journal_lines", :force => true do |t|
    t.integer  "journal_id",            :limit => 11
    t.integer  "referenced_journal_id", :limit => 11
    t.string   "property"
    t.string   "property_type"
    t.string   "old_value"
    t.string   "new_value"
    t.integer  "property_id",           :limit => 11
  end

  create_table "journals", :force => true do |t|
    t.integer  "journalized_id",   :limit => 11
    t.string   "journalized_type"
    t.integer  "actor_id",         :limit => 11
    t.datetime "created_at"
  end
  
  create_table "people", :force => true do |t|
    t.string   "has_person_type"
    t.integer  "has_person_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "photo_file_name"
    t.integer  "photo_file_size"
    t.string   "photo_content_type"
  end
  
  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "area"
  end
  
  create_table "schools", :force => true do |t|
    t.string   "name"
    t.integer  "district_id"
  end
end
