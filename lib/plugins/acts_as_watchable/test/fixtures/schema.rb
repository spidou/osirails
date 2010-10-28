ActiveRecord::Schema.define do
  create_table "watchable_functions", :force => true do |t|
    t.string  "watchable_type"
    t.string  "name"
    t.string  "description"
    t.boolean "on_modification"
    t.boolean "on_schedule"
  end

  add_index "watchable_functions", ["name", "watchable_type"], :name => "index_watchable_functions_on_name_and_watchable_type", :unique => true
  
  create_table "watchings", :force => true do |t|
    t.integer "watchable_id"
    t.string  "watchable_type"
    t.integer "watcher_id"
    t.boolean "all_changes"
  end

  add_index "watchings", ["watchable_id", "watchable_type", "watcher_id"], :name => "unique_index_watchings", :unique => true
  add_index "watchings", ["watchable_id", "watchable_type"], :name => "index_watchings_on_watchable_id_and_watchable_type"
  add_index "watchings", ["watcher_id"], :name => "index_watchings_on_watcher_id"
    
  create_table "watchings_watchable_functions", :force => true do |t|
    t.integer "watching_id"
    t.integer "watchable_function_id"
    t.boolean "on_modification"
    t.boolean "on_schedule"
    t.string  "time_quantity"
    t.string  "time_unity"
  end

  add_index "watchings_watchable_functions", ["watching_id", "watchable_function_id"], :name => "unique_index_watchings_watchable_functions", :unique => true
    
  create_table :people, :force => true do |t|
    t.string  :has_person_type
    t.integer :has_person_id
    t.string  :first_name
    t.string  :last_name
    t.string  :photo_file_name
    t.integer :photo_file_size
    t.string  :photo_content_type
  end
  
  create_table :districts, :force => true do |t|
    t.string  :name
    t.integer :area
  end
  
  create_table :schools, :force => true do |t|
    t.string  :name
    t.integer :district_id
  end
end
