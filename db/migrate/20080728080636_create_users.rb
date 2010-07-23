class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :username, :password
      t.boolean  :enabled
      t.datetime :password_updated_at, :last_connection, :last_activity
      
      t.timestamps
    end
    
    add_index :users, :username, :unique => true
  end
  
  def self.down
    drop_table :users
  end
end
