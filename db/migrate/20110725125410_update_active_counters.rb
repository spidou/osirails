class UpdateActiveCounters < ActiveRecord::Migration
  def self.up
    remove_index :active_counters, :key
    add_column :active_counters, :model, :string
    add_index :active_counters, [:model, :key], :unique => true
    
    ActiveCounter.update_all_counters
  end

  def self.down
    remove_index :active_counters, [:model, :key]
    remove_column :active_counters, :model
    add_index :active_counters, :key, :unique => true
  end
end
