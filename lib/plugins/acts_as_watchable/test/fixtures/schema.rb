ActiveRecord::Schema.define do
   
    create_table    :watchables, :force => true do |t|
      t.integer     :has_watchable_id
      t.string      :has_watchable_type
      t.integer     :watcher_id
      t.boolean     :all_changes
    end
    
    create_table    :watchables_watchable_functions, :force => true do |t|
      t.integer     :watchable_id 
      t.integer     :watchable_function_id
      t.boolean     :on_modification
      t.boolean     :on_schedule
      t.string      :time_quantity 
      t.string      :time_unity 
    end
    
    create_table  :watchable_functions, :force => true do |t|
      t.string    :function_type
      t.string    :function_name
      t.string    :function_description
      t.boolean   :on_modification
      t.boolean   :on_schedule
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
