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

ActiveRecord::Schema.define(:version => 20080721101446) do

  create_table "business_object_permissions", :force => true do |t|
    t.boolean  "list"
    t.boolean  "view"
    t.boolean  "add"
    t.boolean  "edit"
    t.boolean  "delete"
    t.integer  "role_id",             :limit => 11
    t.string   "has_permission_type"
    t.integer  "has_permission_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "page_permissions", :force => true do |t|
    t.boolean  "list"
    t.boolean  "view"
    t.boolean  "add"
    t.boolean  "edit"
    t.boolean  "delete"
    t.integer  "role_id",    :limit => 11
    t.integer  "page_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title_link"
    t.string   "description_link"
    t.string   "url"
    t.string   "name"
    t.integer  "position",         :limit => 11
    t.integer  "parent_id",        :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
