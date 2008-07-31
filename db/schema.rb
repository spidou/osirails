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

ActiveRecord::Schema.define(:version => 20080731044815) do

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

  create_table "content_versions", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.integer  "menu_id",      :limit => 11
    t.integer  "content_id",   :limit => 11
    t.string   "contributor"
    t.datetime "versioned_at"
  end

  create_table "contents", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.text     "text"
    t.integer  "menu_id",      :limit => 11
    t.string   "author"
    t.string   "contributors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.text     "dependencies"
    t.text     "conflicts"
    t.boolean  "installed",        :default => false, :null => false
    t.boolean  "activated",        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "business_objects"
  end

  create_table "menu_permissions", :force => true do |t|
    t.boolean  "list"
    t.boolean  "view"
    t.boolean  "add"
    t.boolean  "edit"
    t.boolean  "delete"
    t.integer  "role_id",    :limit => 11
    t.integer  "menu_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "url"
    t.string   "name"
    t.integer  "position",    :limit => 11
    t.integer  "parent_id",   :limit => 11
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

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.boolean  "enabled"
    t.datetime "expire_date"
    t.datetime "last_connection"
    t.integer  "employee_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
