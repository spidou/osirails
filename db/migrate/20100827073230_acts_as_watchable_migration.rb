class ActsAsWatchableMigration < ActiveRecord::Migration
  def self.up
    create_table :watchings do |t|
      t.references  :watchable, :polymorphic => true
      t.references  :watcher
      t.boolean     :all_changes, :default => false
    end
    
    add_index :watchings, [:watchable_id, :watchable_type, :watcher_id], :unique => true, :name => :unique_index_watchings
    add_index :watchings, :watcher_id
    add_index :watchings, [:watchable_id, :watchable_type]
    
    create_table :watchings_watchable_functions do |t|
      t.references  :watching, :watchable_function
      t.boolean     :on_modification, :on_schedule, :default => false
      t.string      :time_quantity, :time_unity 
    end
    
    add_index :watchings_watchable_functions, [:watching_id, :watchable_function_id], :unique => true, :name => :unique_index_watchings_watchable_functions
    
    create_table :watchable_functions do |t|
      t.string  :watchable_type, :name, :description
      t.boolean :on_modification, :on_schedule, :default => false
    end
    
    add_index :watchable_functions, [:name, :watchable_type], :unique => true
  end
  
  def self.down
    drop_table :watchings
    drop_table :watchings_watchable_functions
    drop_table :watchable_functions
  end
end
