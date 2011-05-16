ActiveRecord::Schema.define do

  create_table "people", :force => true do |t|
    t.column "name",       :string
    t.column "identifier", :string
    t.column "gender_id",  :integer,   :limit => 11
    t.column "age",        :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "relationships", :force => true do |t|
    t.column "person_id",  :integer,   :limit => 11
    t.column "friend_id",  :integer,   :limit => 11
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "familly_relationships", :force => true do |t|
    t.column "person_id",  :integer,   :limit => 11
    t.column "love_id",    :integer,   :limit => 11
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "groups", :force => true do |t|
    t.column "name",       :string
    t.column "person_id",  :integer,   :limit => 11
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "favorite_colors_people", :force => true do |t|
    t.column "person_id",         :integer,   :limit => 11
    t.column "favorite_color_id", :integer,   :limit => 11
    t.column "created_at",        :datetime
    t.column "updated_at",        :datetime
  end
  
  create_table "favorite_colors", :force => true do |t|
    t.column "name",       :string
    t.column "hex_code",   :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "genders", :force => true do |t|
    t.column "name",            :string
    t.column "male",            :boolean
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end
  
  create_table "identity_cards", :force => true do |t|
    t.column "number",                 :integer
    t.column "nationality",            :string
    t.column "has_identity_card_id",   :integer,   :limit => 11
    t.column "has_identity_card_type", :string
    t.column "created_at",             :datetime
    t.column "updated_at",             :datetime
  end

  create_table "summer_jobs", :force => true do |t|
    t.column "name",       :string
    t.column "salary",     :integer
    t.column "person_id",  :integer,   :limit => 11
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "numbers", :force => true do |t|
    t.column "value",           :string
    t.column "number_type_id",  :integer,   :limit => 11
    t.column "has_number_id",   :integer,   :limit => 11
    t.column "has_number_type", :string
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end
  
  create_table "number_types", :force => true do |t|
    t.column "name",       :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "dogs", :force => true do |t|
    t.column "race",       :string
    t.column "person_id",  :integer,   :limit => 11
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "people_wishes", :force => true do |t|
    t.column "has_wishes_id",   :integer,   :limit => 11
    t.column "has_wishes_type", :string 
    t.column "wish_id",       :integer,   :limit => 11
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
  end
  
  create_table "people_dreams", :force => true do |t|
    t.column "has_dream_id",   :integer,   :limit => 11
    t.column "has_dream_type", :string 
    t.column "dream_id",       :integer,   :limit => 11
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
  end
  
  create_table "dreams", :force => true do |t|
    t.column "name",       :string
    t.column "description",:text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  create_table "wishes", :force => true do |t|
    t.column "name",       :string
    t.column "description",:text
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end
  
  # Class used to regroup test with many action on many data types
  create_table "data_types", :force => true do |t|
    t.column "a_string",       :string
    t.column "a_text",         :text
    t.column "a_integer",      :integer
    t.column "a_decimal",      :decimal, :precision => 12, :scale => 3
    t.column "a_float",        :float
    t.column "a_boolean",      :boolean
    t.column "a_datetime",     :datetime
    t.column "a_date",         :date
    t.column "a_binary",       :binary
  end
  
  create_table "users", :force => true do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "queries", :force => true do |t|
    t.integer  "creator_id",    :limit => 11
    t.string   "name"
    t.string   "page_name"
    t.string   "quick_search_value" 
    t.string   "search_type"
    t.text     "criteria"
    t.text     "columns"
    t.text     "order"
    t.text     "group"
    t.boolean  "public_access"
    t.integer  "per_page",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
