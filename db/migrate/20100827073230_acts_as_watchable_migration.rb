class ActsAsWatchableMigration < ActiveRecord::Migration
  def self.up
    create_table    :watchables do |t|
      t.references  :has_watchable, :polymorphic => true
      t.references  :watcher
      t.boolean     :all_changes
    end
    
    create_table    :watchables_watchable_functions do |t|
      t.references  :watchable, :watchable_function
      t.boolean     :on_modification, :on_schedule
      t.string      :time_quantity, :time_unity 
    end
    
    create_table  :watchable_functions do |t|
      t.string    :function_type, :function_name, :function_description
      t.boolean   :on_modification, :on_schedule
    end
  end

  def self.down
    drop_table :watchables
    drop_table :watchables_watchable_functions
    drop_table :watchable_functions
  end
end
