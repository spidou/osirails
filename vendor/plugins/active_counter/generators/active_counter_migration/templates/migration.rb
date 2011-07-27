class ActiveCounterMigration < ActiveRecord::Migration
  def self.up
    create_table :active_counters do |t|
      t.string :model, :key, :cast_type
      t.float  :value, :default => 0.0
    end
    
    add_index :active_counters, [:model, :key], :unique => true
  end

  def self.down
    drop_table :active_counters
  end
end
